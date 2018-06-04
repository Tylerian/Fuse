import Foundation

public class Channel<T: ChannelUnsafe> {
    internal let unsafe: T
    
    fileprivate init() {
        self.unsafe = T()
    }
    
    public func connect(to host: String, port: Int) {
        fatalError("Channel.connect(_:_:) method must be overriden at inheriting class!")
    }
    
    public func disconnect() {
        fatalError("Channel.disconnect() method must be overriden at inheriting class!")
    }
    
    public func write(_ message: Any) {
        fatalError("Channel.write(_:) method must be overriden at inheriting class!")
    }
}

public protocol ChannelUnsafe {
    init()
    
    func open(host: String, port: Int)
    func close()
    
    func write(_ message: ByteBuffer)
}

public final class StreamingChannel: Channel<ChannelStream> {
    internal unowned var pipeline: ChannelPipeline
    
    public init(pipeline: ChannelPipeline) {
        self.pipeline = pipeline
    }
    
    public override func connect(to host: String, port: Int) {
        self.pipeline.connect(to: host, port: port)
    }
    
    public override func disconnect() {
        self.pipeline.disconnect()
    }
    
    public override func write(_ message: Any) {
        self.pipeline.write(message)
    }
}

public class ChannelStream: NSObject {
    private let input: InputStream
    private let output: OutputStream
    
    private var buffer: [UInt8]
    
    private var writable: Bool = false
    fileprivate var delegate: ChannelStreamDelegate?
    
    private let kDefaultBufferSize = 1024
    
    fileprivate init(host: String, port: Int)
    {
        var a: InputStream?
        var b: OutputStream?
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &a, outputStream: &b)
        
        guard let input = a, let output = b else {
            fatalError("Error while attempting to get streams for host: \(host) and port: \(port)")
        }
        
        self.input  = input
        self.output = output
        self.buffer = [UInt8](repeating: 0, count: kDefaultBufferSize)
    }
}

extension ChannelStream: ChannelUnsafe {
    
    public func open() {
        self.input.schedule(in: .current, forMode: .defaultRunLoopMode)
        self.output.schedule(in: .current, forMode: .defaultRunLoopMode)
        
        self.input.open()
        self.output.open()
    }
    
    public func close() {
        self.input.close()
        self.input.close()
        
        self.input.remove(from: .current, forMode: .defaultRunLoopMode)
        self.input.remove(from: .current, forMode: .defaultRunLoopMode)
    }
    
    public func write(_ bytes: ByteBuffer) {
        if writable {
            
        }
    }
}

extension ChannelStream: StreamDelegate {
    public func stream(_ stream: Stream, handle event: Stream.Event) {
        print("stream(_ stream: \(stream), handle event: \(event)")
        
        switch (stream, event) {
        case (_, .errorOccurred):
            if let error = stream.streamError {
                self.delegate?.stream(self, hasCaughtError: error)
            }
            break
        case (self.input, .openCompleted):
            self.delegate?.stream(opened: self)
            break
        case (self.input, .endEncountered):
            self.delegate?.stream(closed: self)
            break
        case (self.input, .hasBytesAvailable):
            let available = self.input.read(&self.buffer, maxLength: kDefaultBufferSize)
            self.delegate?.stream(self, hasBytesAvailable: &self.buffer[0 ..< available])
            break
        case (self.output, .hasSpaceAvailable):
            // TODO: Write from outbuffer
            break
        default:
            break
        }
    }
}

fileprivate protocol ChannelStreamDelegate: class {
    func stream(opened stream: ChannelStream)
    func stream(closed stream: ChannelStream)
    
    func stream(_ stream: ChannelStream, hasCaughtError error: Error)
    func stream(_ stream: ChannelStream, hasBytesAvailable bytes: inout ArraySlice<UInt8>)
}

extension StreamingChannel: ChannelStreamDelegate {
    fileprivate func stream(opened stream: ChannelStream) {
        self.pipeline.fireChannelActive()
    }
    
    fileprivate func stream(closed stream: ChannelStream) {
        self.pipeline.fireChannelInactive()
    }
    
    fileprivate func stream(_ stream: ChannelStream, hasCaughtError error: Error) {
        self.pipeline.fireErrorCaught(error)
    }
    
    fileprivate func stream(_ stream: ChannelStream, hasBytesAvailable bytes: inout ArraySlice<UInt8>) {
        self.pipeline.fireChannelRead(bytes)
    }
}
