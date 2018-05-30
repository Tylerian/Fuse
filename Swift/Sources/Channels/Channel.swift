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
    private var stream: ChannelStream?
    
    public unowned var pipeline: ChannelPipeline
    
    public init(pipeline: ChannelPipeline) {
        self.pipeline = pipeline
    }
    
    public func close() {
        guard let stream = self.stream else {
            return
        }
        
        stream.close()
    }
    
    public func connect(to host: String, port: Int) {
        self.stream = ChannelStream(host: host, port: port)
        
        guard let stream = self.stream else {
            return
        }
        
        stream.open()
    }
    
    public func flush() {
        self.pipeline.flush()
    }
    
    public func write(_ message: AnyObject) {
        self.pipeline.fire(write: message)
    }
    
    public func write(flushing message: AnyObject) {
        self.pipeline.fire(write: message, flushing: true)
    }
}

extension StreamChannel: ChannelStreamDelegate {
    func stream(opened stream: ChannelStream) {
        self.pipeline.fire(channelConnected: self)
    }
    
    func stream(closed stream: ChannelStream) {
        self.pipeline.fire(channelClosed: self)
    }
    
    func stream(_ stream: ChannelStream, hasCaughtError error: Error) {
        self.pipeline.fire(errorCaught: error)
    }
    
    func stream(_ stream: ChannelStream, hasBytesAvailable bytes: inout ArraySlice<UInt8>) {
        self.pipeline.fire(channelRead: bytes)
    }
    
    func stream(_ stream: ChannelStream, hasSpaceAvailable length: Int) {
        
    }
}
