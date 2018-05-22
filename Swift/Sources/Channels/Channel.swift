import Foundation

public protocol Channel {
    var pipeline: ChannelPipeline { get }
    
    func connect(to host: String, port: Int)
    
    func write(_ object: AnyObject)
}

public protocol ChannelDelegate {
    func channel(connected channel: Channel)
    func channel(disconnected channel: Channel)
}

public final class StreamChannel: Channel {
    
    unowned var pipeline: ChannelPipeline
    
    public init(pipeline: ChannelPipeline) {
        self.pipeline = pipeline
    }
    
    public func connect(to host: String, port: Int) {
        
    }
}
