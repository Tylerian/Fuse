import Foundation

public protocol Channel {
    var pipeline: ChannelPipeline { get }
    
    func close()
    func connect(to host: String, port: Int)
    
    func flush()
    
    func write(_ message: AnyObject)
    func write(flushing message: AnyObject)
}

public protocol ChannelDelegate {
    func channel(closed channel: Channel)
    func channel(connected channel: Channel)
}

public final class StreamChannel: Channel {
    
    unowned var pipeline: ChannelPipeline
    
    public init(pipeline: ChannelPipeline) {
        self.pipeline = pipeline
    }
    
    public func connect(to host: String, port: Int) {
        
    }
}
