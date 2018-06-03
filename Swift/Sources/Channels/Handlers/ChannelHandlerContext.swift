//
//  ChannelHandlerContext.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public final class ChannelHandlerContext {
    public let name: String
    public let handler: ChannelHandler
    
    public var next: ChannelHandlerContext?
    public var prev: ChannelHandlerContext?
    
    internal init(name: String, handler: ChannelHandler) {
        self.name    = name
        self.handler = handler
    }
}

extension ChannelHandlerContext: InboundChannelHandlerInvoker {
    public func fireChannelActive() {
        self.next?.triggerChannelActive()
    }
    
    public func fireChannelInactive() {
        self.next?.triggerChannelInactive()
    }
    
    public func fireErrorCaught(_ error: Error) {
        self.next?.triggerErrorCaught(error)
    }
    
    public func fireChannelRead(_ message: Any) {
        self.next?.triggerChannelRead(message)
    }
    
    internal func triggerChannelActive() {
        guard let handler = handler as? InboundChannelHandler else {
            return
        }
        
        handler.channel(active: self)
    }
    
    internal func triggerChannelInactive() {
        guard let handler = handler as? InboundChannelHandler else {
            return
        }
        
        handler.channel(inactive: self)
    }
    
    internal func triggerErrorCaught(_ error: Error) {
        guard let handler = handler as? InboundChannelHandler else {
            return
        }
        
        handler.channel(self, error: error)
    }
    
    internal func triggerChannelRead(_ message: Any) {
        guard let handler = handler as? InboundChannelHandler else {
            return
        }
        
        handler.channel(self, read: message)
    }
}

extension ChannelHandlerContext: OutboundChannelHandlerInvoker {
    public func connect(to host: String, port: Int) {
        self.prev?.triggerConnect(to: host, port: port)
    }
    
    public func disconnect() {
        self.prev?.triggerDisconnect()
    }
    
    public func write(_ message: Any) {
        self.prev?.triggerWrite(message)
    }
    
    internal func triggerConnect(to host: String, port: Int) {
        guard let handler = handler as? OutboundChannelHandler else {
            return
        }
        
        handler.channel(connect: self, to: host, port: port)
    }
    
    internal func triggerDisconnect() {
        guard let handler = handler as? OutboundChannelHandler else {
            return
        }
        
        handler.channel(disconnect: self)
    }
    
    internal func triggerWrite(_ message: Any) {
        guard let handler = handler as? OutboundChannelHandler else {
            return
        }
        
        handler.channel(self, write: message)
    }
}
