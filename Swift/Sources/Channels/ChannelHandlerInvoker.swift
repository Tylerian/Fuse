import Foundation

public protocol InboundChannelHandlerInvoker {
    func fireChannelActive()
    func fireChannelInactive()
    func fireChannelRead(_ data: Any)
    
    func fireError(_ error: Error)
}

public protocol OutboundChannelHandlerInvoker {
    func close()
    func connect(to host: String, port: Int)
    
    func write(_ data: Any)
}

public typealias ChannelHandlerInvoker = InboundChannelHandlerInvoker & OutboundChannelHandlerInvoker
