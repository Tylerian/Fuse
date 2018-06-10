import Foundation

public final class Bootstrap {
    private let _initializer: ChannelInitializer
    
    public init(initializer: @escaping ChannelInitializer) {
        self._initializer = initializer
    }
}

extension Bootstrap {
    public func connect(to host: String, port: Int) throws -> Channel {
        let channel = Channel(socket: { channel in
            let socket = TCPSocket(queue: channel.pipeline.executor)
                socket.delegate = channel
         return socket
        })
        
        try self._initializer(channel)
    
        channel.pipeline.connect(to: host, port: port)
        
        return channel
    }
}

public typealias ChannelInitializer = (Channel) throws -> Void
