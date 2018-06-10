import Foundation

public final class Channel {
    private var _socket: Socket!
    private var _pipeline: ChannelPipeline!
    
    internal init(socket factory: (Channel) -> Socket) {
        self._pipeline = ChannelPipeline(channel: self)
        self._socket   = factory(self)
    }
}

extension Channel {
    public var pipeline: ChannelPipeline {
        return self._pipeline
    }
}

extension Channel {
    internal var socket: Socket {
        return self._socket
    }
}

extension Channel: SocketDelegate {
    internal func socket(opened socket: Socket) {
        self.pipeline.fireChannelActive()
    }
    
    internal func socket(closed socket: Socket) {
        self.pipeline.fireChannelInactive()
    }
    
    internal func socket(_ socket: Socket, hasCaughtError error: Error) {
        self.pipeline.fireError(error)
    }
    
    internal func socket(_ socket: Socket, hasBytesAvailable bytes: ArraySlice<UInt8>) {
        self.pipeline.fireChannelRead(bytes)
    }
}

internal protocol Socket: class {
    var delegate: SocketDelegate? { get set }
    
    func close() throws
    func connect(to host: String, port: Int) throws
    
    func read() throws
    func write(data: Any) throws
}

internal protocol SocketDelegate: class {
    func socket(opened socket: Socket)
    func socket(closed socket: Socket)
    
    func socket(_ socket: Socket, hasCaughtError error: Error)
    func socket(_ socket: Socket, hasBytesAvailable bytes: ArraySlice<UInt8>)
}

internal final class TCPSocket: NSObject, Socket {
    private var _direct: Bool
    private var _rcvbuf: [UInt8]
    private var _sndbuf: ByteBuffer
    
    unowned
    private let _queue: DispatchQueue
    
    private var _input:  InputStream?
    private var _output: OutputStream?
    
    weak
    private var _delegate: SocketDelegate?
    
    internal required init(queue: DispatchQueue) {
        self._queue  = queue
        self._direct = false
        self._rcvbuf = [UInt8](repeating: 0,
               count: kDefaultRcvBufferCapacity)
        self._sndbuf = UnsafeByteBuffer(
            capacity: kDefaultSndBufferCapacity)
    }
}

extension TCPSocket {
    internal var delegate: SocketDelegate? {
        get {
            return self._delegate
        }
        set(value) {
            self._delegate = value
        }
    }
}

extension TCPSocket {
    internal func close() throws {
        guard let input = self._input, let output = self._output else {
            throw ChannelError.failedToGetStreams
        }
        
        if input .streamStatus == .closed,
           output.streamStatus == .closed {
            throw ChannelError.alreadyClosed
        }
        
        input.close()
        output.close()
        
        CFReadStreamSetDispatchQueue (self._input,  nil)
        CFWriteStreamSetDispatchQueue(self._output, nil)
    }
    
    internal func connect(to host: String, port: Int) throws {
        Stream.getStreamsToHost(
            withName: host, port: port,
            inputStream: &self._input, outputStream: &self._output)
        
        guard let input = self._input, let output = self._output else {
            throw ChannelError.failedToGetStreams
        }
        
        if input.streamStatus == .open, output.streamStatus == .open {
            throw ChannelError.alreadyConnected
        }
        
        if output.streamStatus == .opening, output.streamStatus == .opening {
            throw ChannelError.alreadyConnecting
        }
        
        input.delegate = self
        output.delegate = self
        
        CFReadStreamSetDispatchQueue (self._input,  self._queue)
        CFWriteStreamSetDispatchQueue(self._output, self._queue)
        
        input .open()
        output.open()
    }
}

extension TCPSocket: StreamDelegate {
    public func stream(_ stream: Stream, handle event: Stream.Event) {
        do {
            switch (stream, event) {
            case(_output, .openCompleted):
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
                try self.write()
                break
            default:
                break
            }
        } catch let error {
            self._delegate?.socket(self, hasCaughtError: error)
        }
    }
}

extension TCPSocket {
    internal func read() throws {
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
    internal func write(data: Any) throws {
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
            try self.write()
        }
    }

    internal func write() throws {
        guard let output = self._output else {
            throw SocketError.notInitialized
        }
        
        guard self._sndbuf.readable else {
            self._direct = true
            return
        }
        
        let sndsize = self._sndbuf.readableBytes >= kDefaultSndBufferPageSize ? kDefaultSndBufferPageSize : self._sndbuf.readableBytes
        let written = output.write(self._sndbuf.unsafe + self._sndbuf.readerIndex, maxLength: sndsize)
        
        if written > 0 {
            self._direct = false
            self._sndbuf.readerIndex += written
        } else if written == -1 {
            throw SocketError.ioError(output.streamError)
        }
    }
}

public enum ChannelError: Error {
    case failedToGetStreams
    case alreadyClosed
    case alreadyConnected
    case alreadyConnecting
}

public enum SocketError: Error {
    case closed
    case ioError(_: Error?)
    case notInitialized
    case notSupportedOutboundDataType
}

fileprivate let kDefaultRcvBufferCapacity: Int = 1024
fileprivate let kDefaultSndBufferCapacity: Int = 4096
fileprivate let kDefaultSndBufferPageSize: Int = 512
