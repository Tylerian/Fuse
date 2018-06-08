import Foundation

public final class Channel {
    private let _socket: Socket
    private var _pipeline: ChannelPipeline!
    
    internal init(socket factory: () -> Socket) {
        self._socket   = factory()
        self._pipeline = ChannelPipeline(channel: self)
    }
}

extension Channel {
    internal var socket: Socket {
        return self._socket
    }
    
    internal var pipeline: ChannelPipeline {
        return self._pipeline
    }
}

extension Channel: SocketDelegate {
    public func socket(opened socket: Socket) {
        self.pipeline.fireChannelActive()
    }
    
    public func socket(closed socket: Socket) {
        self.pipeline.fireChannelInactive()
    }
    
    public func socket(_ socket: Socket, hasCaughtError error: Error) {
        self.pipeline.fireError(error)
    }
    
    public func socket(_ socket: Socket, hasBytesAvailable bytes: ArraySlice<UInt8>) {
        self.pipeline.fireChannelRead(bytes)
    }
}

public protocol Socket: class {
    var delegate: SocketDelegate? { get set }
    
    init()
    
    func close() throws
    func connect(to host: String, port: Int) throws
    
    func read() throws
    func write(data: Any) throws
}

public protocol SocketDelegate: class {
    func socket(opened socket: Socket)
    func socket(closed socket: Socket)
    
    func socket(_ socket: Socket, hasCaughtError error: Error)
    func socket(_ socket: Socket, hasBytesAvailable bytes: ArraySlice<UInt8>)
}

public final class TCPSocket: NSObject, Socket {
    private var _direct: Bool
    private var _rcvbuf: [UInt8]
    private var _sndbuf: ByteBuffer
    
    private var _input:  InputStream?
    private var _output: OutputStream?
    private var _delegate: SocketDelegate?
    
    public required override init() {
        self._direct = false
        self._rcvbuf = [UInt8](repeating: 0,
               count: kDefaultRcvBufferCapacity)
        self._sndbuf = UnsafeByteBuffer(
            capacity: kDefaultSndBufferCapacity)
    }
}

extension TCPSocket {
    public var delegate: SocketDelegate? {
        get {
            return self._delegate
        }
        set(value) {
            self._delegate = value
        }
    }
}

extension TCPSocket {
    public func close() throws {
        guard let input = self._input, let output = self._output else {
            throw ChannelError.failedToGetStreams
        }
        
        if input .streamStatus == .closed,
           output.streamStatus == .closed {
            throw ChannelError.alreadyClosed
        }
        
        input.close()
        output.close()
        
        input.remove(from: .current, forMode: .defaultRunLoopMode)
        output.remove(from: .current, forMode: .defaultRunLoopMode)
    }
    
    public func connect(to host: String, port: Int) throws {
        Stream.getStreamsToHost(
            withName: host, port: port,
            inputStream: &self._input, outputStream: &self._output)
        
        guard let input = self._input, let output = self._output else {
            throw ChannelError.failedToGetStreams
        }
        
        input .schedule(in: .current, forMode: .defaultRunLoopMode)
        output.schedule(in: .current, forMode: .defaultRunLoopMode)
        
        input .open()
        output.open()
    }
}

extension TCPSocket {
    public func read() throws {
        guard let input = self._input else {
            throw SocketError.notInitialized
        }
        
        let available = input.read(&self._rcvbuf, maxLength: kDefaultRcvBufferCapacity)
        
        if  available == -1 {
            throw SocketError.ioError(input.streamError)
        } else if available != 0 {
            self._delegate?.socket(self, hasBytesAvailable: self._rcvbuf[0 ..< available])
        }
    }
}

extension TCPSocket {
    public func write(data: Any) throws {
        guard let buffer = data as? ByteBuffer else {
            throw SocketError.notSupportedOutboundDataType
        }
        
        // Make space if needed before
        // increasing _sndbuf capacity
        if buffer.readableBytes > self._sndbuf.writableBytes {
            _ = self._sndbuf.discardReadBytes()
        }
        
        _ = self._sndbuf.write(bytes: buffer)
        
        if self._direct {
            try self.write(data: self._sndbuf)
        }
    }

    public func write(data: ByteBuffer) throws {
        guard let output = self._output else {
            throw SocketError.notInitialized
        }
        
        guard self._sndbuf.readable else {
            self._direct = true
            return
        }
        
        let written = output.write(self._sndbuf.unsafe + self._sndbuf.readerIndex, maxLength: self._sndbuf.readableBytes)
        
        if written > 0 {
            self._direct = false
            self._sndbuf.readerIndex += written
        } else if written == -1 {
            throw SocketError.ioError(output.streamError)
        }
    }
}

extension TCPSocket: StreamDelegate {
    public func stream(_ stream: Stream, handle event: Stream.Event) {
        do {
            switch (stream, event) {
            case(_, .openCompleted):
                self._delegate?.socket(opened: self)
                break
            case(_, .errorOccurred):
                throw SocketError.ioError(stream.streamError)
            case (_, .endEncountered):
                self._delegate?.socket(closed: self)
                break
            case (_input, .hasBytesAvailable):
                try self.read()
                break
            case (_output, .hasSpaceAvailable):
                try self.write(data: self._sndbuf)
                break
            default:
                break
            }
        } catch let error {
            self._delegate?.socket(self, hasCaughtError: error)
        }
    }
}

public enum ChannelError: Error {
    case failedToGetStreams
    case alreadyClosed
}

public enum SocketError: Error {
    case closed
    case ioError(_: Error?)
    case notInitialized
    case notSupportedOutboundDataType
}

fileprivate let kDefaultRcvBufferCapacity: Int = 1024
fileprivate let kDefaultSndBufferCapacity: Int = 4096
