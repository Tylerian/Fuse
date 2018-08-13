import Foundation

public final class ChannelHandlerContext {
    private let _name: String
    private let _handler: ChannelHandler
    
    unowned
    private let _executor: DispatchQueue
    
    unowned
    private let _pipeline: ChannelPipeline
    
    private var _next: ChannelHandlerContext?
    private var _prev: ChannelHandlerContext?
    
    internal init(name: String, handler: ChannelHandler, executor: DispatchQueue, pipeline: ChannelPipeline) {
        self._name     = name
        self._handler  = handler
        self._executor = executor
        self._pipeline = pipeline
    }
}

extension ChannelHandlerContext {
    public var name: String {
        return self._name
    }
    
    public var channel: Channel {
        return self._pipeline.channel
    }
    
    public var pipeline: ChannelPipeline {
        return self._pipeline
    }
}

extension ChannelHandlerContext {
    internal var handler: ChannelHandler {
        return self._handler
    }
    
    internal var executor: DispatchQueue {
        return self._executor
    }
    
    internal var next: ChannelHandlerContext? {
        get {
            return self._next
        }
        
        set (value) {
            self._next = value
        }
    }
    
    internal var prev: ChannelHandlerContext? {
        get {
            return self._prev
        }
        
        set (value) {
            self._prev = value
        }
    }
}

extension ChannelHandlerContext: InboundChannelHandlerInvoker {
    public func fireChannelActive() {
        self._next?.triggerChannelActive()
    }
    
    public func fireChannelInactive() {
        self._next?.triggerChannelInactive()
    }
    
    public func fireChannelRead(_ data: Any) {
        self._next?.triggerChannelRead(data)
    }
    
    public func fireError(_ error: Error) {
        self._next?.triggerError(error)
    }
}

extension ChannelHandlerContext {
    private func triggerChannelActive() {
        let cast = self._handler as? InboundChannelHandler
        
        guard let handler = cast else {
            self.fireChannelActive()
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.channel(active: ctx)
            } catch let error {
                ctx.triggerError(error)
            }
        }
    }
    
    private func triggerChannelInactive() {
        let cast = self._handler as? InboundChannelHandler
        
        guard let handler = cast else {
            self.fireChannelInactive()
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.channel(inactive: ctx)
            } catch let error {
                ctx.triggerError(error)
            }
        }
    }
    
    private func triggerChannelRead(_ data: Any) {
        let cast = self._handler as? InboundChannelHandler
        
        guard let handler = cast else {
            self.fireChannelRead(data)
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.channel(ctx, read: data)
            } catch let error {
                ctx.triggerError(error)
            }
        }
    }
    
    private func triggerError(_ error: Error) {
        let cast = self._handler as? InboundChannelHandler
        
        guard let handler = cast else {
            self.fireError(error)
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.handler(ctx, error: error)
            } catch let error {
                print("[ERROR] -- An error was thrown by a user handler while handling an handler(error:) event.")
                print("[ERROR] -- \(String(describing: error))")
            }
        }
    }
}

extension ChannelHandlerContext: OutboundChannelHandlerInvoker {
    public func close() {
        self._prev?.triggerClose()
    }
    
    public func connect(to host: String, port: Int) {
        self._prev?.triggerConnect(to: host, port: port)
    }
    
    public func write(_ data: Any) {
        print("Triggerin write on #\(_prev?.name)")
        self._prev?.triggerWrite(data)
    }
}

extension ChannelHandlerContext {
    private func triggerClose() {
        let cast = self._handler as? OutboundChannelHandler
        
        guard let handler = cast else {
            self.close()
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.channel(close: ctx)
            } catch let error {
                ctx.triggerError(error)
            }
        }
    }
    
    private func triggerConnect(to host: String, port: Int) {
        let cast = self._handler as? OutboundChannelHandler
        
        guard let handler = cast else {
            self.connect(to: host, port: port)
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.channel(connect: ctx, to: host, port: port)
            } catch let error {
                ctx.triggerError(error)
            }
        }
    }
    
    private func triggerWrite(_ data: Any) {
        let cast = self._handler as? OutboundChannelHandler
        
        guard let handler = cast else {
            self.write(data)
            return
        }
        
        self.executor.async(flags: .barrier) { [weak self] in
            guard let ctx = self else {
                return
            }
            
            do {
                try handler.channel(ctx, write: data)
            } catch let error {
                ctx.triggerError(error)
            }
        }
    }
}
