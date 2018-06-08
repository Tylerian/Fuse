import Foundation

public protocol ChannelHandler {
    func handler(added context: ChannelHandlerContext) throws
    func handler(removed context: ChannelHandlerContext) throws
    
    func handler(_ context: ChannelHandlerContext, error: Error) throws
}

extension ChannelHandler {
    public func handler(added context: ChannelHandlerContext) throws {
        // Discard event by default
    }
    
    public func handler(removed context: ChannelHandlerContext) throws {
        // Discard event by default
    }
    
    public func handler(_ context: ChannelHandlerContext, error: Error) throws {
        // Broadcast event to next handler in pipeline
        context.fireError(error)
    }
}

public protocol InboundChannelHandler: ChannelHandler {
    func channel(active context: ChannelHandlerContext) throws
    func channel(inactive context: ChannelHandlerContext) throws
    
    func channel(_ context: ChannelHandlerContext, read data: Any) throws
}

extension InboundChannelHandler {
    public func channel(active context: ChannelHandlerContext) throws {
        // Broadcast event to next handler in pipeline
        context.fireChannelActive()
    }
    
    public func channel(inactive context: ChannelHandlerContext) throws {
        // Broadcast event to next handler in pipeline
        context.fireChannelInactive()
    }
    
    public func channel(_ context: ChannelHandlerContext, read data: Any) throws {
        // Broadcast event to next handler in pipeline
        context.fireChannelRead(data)
    }
}

public protocol OutboundChannelHandler: ChannelHandler {
    func channel(close context: ChannelHandlerContext) throws
    func channel(connect context: ChannelHandlerContext, to host: String, port: Int) throws
    
    func channel(_ context: ChannelHandlerContext, write data: Any) throws
}

extension OutboundChannelHandler {
    public func channel(close context: ChannelHandlerContext) throws {
        // Broadcast event to next handler in pipeline
        context.close()
    }
    
    public func channel(connect context: ChannelHandlerContext, to host: String, port: Int) throws {
        // Broadcast event to next handler in pipeline
        context.connect(to: host, port: port)
    }
    
    public func channel(_ context: ChannelHandlerContext, write data: Any) throws {
        // Broadcast event to next handler in pipeline
        context.write(data)
    }
}

public typealias DuplexChannelHandler = InboundChannelHandler & OutboundChannelHandler
