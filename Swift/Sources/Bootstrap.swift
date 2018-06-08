import Foundation

public final class Bootstrap {
    
    public func connect(to host: String, port: Int) throws -> Channel {
        
        let channel = Channel(socket: {
            return TCPSocket()
        })
        
        return channel
    }
}
