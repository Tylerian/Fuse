import Foundation

/// ```
///                                                    I/O Request
///                                                    via `Channel` or
///                                                    `ChannelHandlerContext`
///                                                      |
///  +---------------------------------------------------+---------------+
///  |                           ChannelPipeline         |               |
///  |                                TAIL              \|/              |
///  |    +---------------------+            +-----------+----------+    |
///  |    | Inbound Handler  N  |            | Outbound Handler  1  |    |
///  |    +----------+----------+            +-----------+----------+    |
///  |              /|\                                  |               |
///  |               |                                  \|/              |
///  |    +----------+----------+            +-----------+----------+    |
///  |    | Inbound Handler N-1 |            | Outbound Handler  2  |    |
///  |    +----------+----------+            +-----------+----------+    |
///  |              /|\                                  .               |
///  |               .                                   .               |
///  | ChannelHandlerContext.fireIN_EVT() ChannelHandlerContext.OUT_EVT()|
///  |        [ method call]                       [method call]         |
///  |               .                                   .               |
///  |               .                                  \|/              |
///  |    +----------+----------+            +-----------+----------+    |
///  |    | Inbound Handler  2  |            | Outbound Handler M-1 |    |
///  |    +----------+----------+            +-----------+----------+    |
///  |              /|\                                  |               |
///  |               |                                  \|/              |
///  |    +----------+----------+            +-----------+----------+    |
///  |    | Inbound Handler  1  |            | Outbound Handler  M  |    |
///  |    +----------+----------+            +-----------+----------+    |
///  |              /|\             HEAD                 |               |
///  +---------------+-----------------------------------+---------------+
///                  |                                  \|/
///  +---------------+-----------------------------------+---------------+
///  |               |                                   |               |
///  |       [ Socket.read ]                    [ Socket.write ]         |
///  |                                                                   |
///  |    Fuse Internal I/O Threads (Transport Implementation)           |
///  +-------------------------------------------------------------------+
/// ```
public final class ChannelPipeline {
    unowned
    private let _channel: Channel
    private let _executor: DispatchQueue
    
    private var _head: ChannelHandlerContext?
    private var _tail: ChannelHandlerContext?
    
    init(channel: Channel) {
        self._channel  = channel
        self._executor = DispatchQueue(label: "io.fuse.pipeline.executor")
        self._head = ChannelHandlerContext(name: "pipeline_head_handler", handler: HeadChannelHandler(), executor: self._executor, pipeline: self)
        self._tail = ChannelHandlerContext(name: "pipeline_tail_handler", handler: TailChannelHandler(), executor: self._executor, pipeline: self)
        
        self._head?.next = self._tail
        self._tail?.prev = self._head
    }
    
    deinit {
        self.destroy()
    }
}

extension ChannelPipeline {
    internal var channel: Channel {
        return self._channel
    }
    
    internal var executor: DispatchQueue {
        return self._executor
    }
}

extension ChannelPipeline {
    private func destroy() {
        var ctx = self._head
        
        while ctx !== self._tail, ctx != nil {
            ctx = ctx?.next
            ctx?.next = nil
            ctx?.prev = nil
        }
        
        self._head = nil
        self._tail = nil
    }
}

extension ChannelPipeline {
    public func add(handler: ChannelHandler, named name: String, first: Bool = false, executor: DispatchQueue? = nil) throws {
        if first {
            try self.add(handler: handler, named: name, before: TailChannelHandler.name)
        } else {
            try self.add(handler: handler, named: name, after: HeadChannelHandler.name)
        }
    }
    
    public func add(handler: ChannelHandler, named name: String, after existing: String, executor: DispatchQueue? = nil) throws {
        try self.executor.sync { [weak self] in
            guard let this = self else {
                return
            }
            
            if check(duplicity: name) {
                throw ChannelPipelineError.handlerNameAlreadyExists
            }
            
            guard let nextctx = this.find(context: existing, unsafe: true) else {
                throw ChannelPipelineError.contextNotFound(name: existing)
            }
            
            let context = ChannelHandlerContext(name: name, handler: handler, executor: executor ?? this.executor, pipeline: this)
            
            this.add(context: context, after: nextctx)
        }
    }
    
    public func add(handler: ChannelHandler, named name: String, before existing: String, executor: DispatchQueue? = nil) throws {
        try self.executor.sync { [weak self] in
            guard let this = self else {
                return
            }
            
            if check(duplicity: name) {
                throw ChannelPipelineError.handlerNameAlreadyExists
            }
            
            guard let prevctx = this.find(context: existing, unsafe: true) else {
                throw ChannelPipelineError.contextNotFound(name: existing)
            }
            
            let context = ChannelHandlerContext(name: name, handler: handler, executor: executor ?? this.executor, pipeline: this)
            
            this.add(context: context, before: prevctx)
        }
    }
    
    private func add(context: ChannelHandlerContext, after existing: ChannelHandlerContext) {
        print("Adding context #\(context.name) after #\(existing.name)")
        context.prev = existing;
        context.next = existing.next;
        existing.next?.prev = context;
        existing.next = context;
    }
    
    private func add(context: ChannelHandlerContext, before existing: ChannelHandlerContext) {
        context.prev = existing.prev;
        context.next = existing;
        existing.prev?.next = context;
        existing.prev = context;
    }
    
    private func check(duplicity name: String) -> Bool {
        var nxt = self._head
        
        while let ctx = nxt {
            if ctx.name == name {
                return true
            }
            
            nxt = ctx.next
        }
        
        return false
    }
    
    private func find(context name: String, unsafe: Bool = false) -> ChannelHandlerContext? {
        var nxt = unsafe ? self._head : self._head?.next
        
        while let ctx = nxt, unsafe && ctx !== self._tail {
            if ctx.name == name {
                return ctx
            }
            
            nxt = ctx.next
        }
        
        return nil
    }
}

extension ChannelPipeline {
    public func remove(handler name: String) throws {
        guard name != self._head?.name,
              name != self._tail?.name else {
            return
        }
        
        guard let ctx = self.find(context: name) else {
            throw ChannelPipelineError.contextNotFound(name: name)
        }
        
        try self.remove(handler: ctx.handler)
    }
    
    public func remove(handler: ChannelHandler) throws {
        
    }
    
    public func replace(handler name: String, with handler: ChannelHandler, named: String) {
        
    }
    
    private func remove(context: ChannelHandlerContext) {
        let prev = context.prev
        let next = context.next
        
        prev?.next = next
        next?.prev = prev
        
        // Break refernce cycles
        context.next = nil
        context.prev = nil
    }
    
    private func replace(context oldctx: ChannelHandlerContext, with newctx: ChannelHandlerContext) {
        let prev = oldctx.prev
        let next = oldctx.next
        
        prev?.next = newctx
        next?.prev = newctx
        
        // update the reference to the replacement so
        // forward of buffered content will work correctly
        oldctx.prev = newctx
        oldctx.next = newctx
    }
}

extension ChannelPipeline: InboundChannelHandlerInvoker {
    public func fireChannelActive() {
        print("Pipeline -> Firing channel active event")
        self._head?.fireChannelActive()
    }
    
    public func fireChannelInactive() {
        self._head?.fireChannelInactive()
    }
    
    public func fireChannelRead(_ data: Any) {
        self._head?.fireChannelRead(data)
    }
    
    public func fireError(_ error: Error) {
        self._head?.fireError(error)
    }
}

extension ChannelPipeline: OutboundChannelHandlerInvoker {
    public func close() {
        self._tail?.close()
    }
    
    public func connect(to host: String, port: Int) {
        self._tail?.connect(to: host, port: port)
    }
    
    public func write(_ data: Any) {
        self._tail?.write(data)
    }
}

public enum ChannelPipelineError: Error {
    case handlerNameAlreadyExists
    case contextNotFound(name: String)
}

fileprivate final class HeadChannelHandler: OutboundChannelHandler {
    static let name: String = "pipeline_head_handler"
    
    func channel(close context: ChannelHandlerContext) throws {
        try context.channel.socket.close()
    }
    
    func channel(connect context: ChannelHandlerContext, to host: String, port: Int) throws {
        try context.channel.socket.connect(to: host, port: port)
    }
    
    func channel(_ context: ChannelHandlerContext, write data: Any) throws {
        try context.channel.socket.write(data: data)
    }
}

fileprivate final class TailChannelHandler: InboundChannelHandler {
    static let name: String = "pipeline_tail_handler"
    
    func handler(_ context: ChannelHandlerContext, error: Error) throws {
        print("[ERROR] -- An error event has reached the tail of the pipeline without being handled.")
        print("[ERROR] -- \(String(describing: error))")
    }
    
    func handler(_ context: ChannelHandlerContext, read data: Any) throws {
        // Discard event
    }
}
