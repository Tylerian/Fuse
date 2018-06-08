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
    public func add(handler: ChannelHandler, named name: String, first: Bool = false, executor: DispatchQueue? = nil) {
        if first {
            self.add(handler: handler, named: name, before: TailChannelHandler.name)
        } else {
            self.add(handler: handler, named: name, after: HeadChannelHandler.name)
        }
    }
    
    public func add(handler: ChannelHandler, named name: String, after existing: String, executor: DispatchQueue? = nil) {
        
    }
    
    public func add(handler: ChannelHandler, named name: String, before existing: String, executor: DispatchQueue? = nil) {
        
    }
    
    private func add(context: ChannelHandlerContext, after existing: String, executor: DispatchQueue? = nil) {
        self.executor.async { [weak self] in
            
        }
    }
    
    private func add(context: ChannelHandlerContext, before existing: String, executor: DispatchQueue? = nil) {
        self.executor.async { [weak self] in
            
        }
    }
}

extension ChannelPipeline {
    public func remove(handler name: String) {
        self.executor.async { [weak self] in
            
        }
    }
    
    public func replace(handler name: String, with handler: ChannelHandler, named: String) {
        self.executor.async { [weak self] in
            
        }
    }
}

extension ChannelPipeline: InboundChannelHandlerInvoker {
    public func fireChannelActive() {
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

fileprivate final class HeadChannelHandler: OutboundChannelHandler {
    static let name: String = "pipeline_head_handler"
    
    func handler(close context: ChannelHandlerContext) throws {
        try context.channel.socket.close()
    }
    
    func handler(connect context: ChannelHandlerContext, to host: String, port: Int) throws {
        try context.channel.socket.connect(to: host, port: port)
    }
    
    func handler(_ context: ChannelHandlerContext, write data: Any) throws {
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
