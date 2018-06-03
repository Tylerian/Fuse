//
//  ChannelHandler.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public protocol ChannelHandler: class {
    func handler(added context: ChannelHandlerContext)
    func handler(removed context: ChannelHandlerContext)
}

extension ChannelHandler {
    public func handler(added context: ChannelHandlerContext) {
        // NOOP
    }
    
    public func handler(removed context: ChannelHandlerContext) {
        // NOOP
    }
}

public protocol InboundChannelHandler: ChannelHandler {
    func channel(active context: ChannelHandlerContext)
    func channel(inactive context: ChannelHandlerContext)
    
    func channel(_ context: ChannelHandlerContext, error: Error)
    func channel(_ context: ChannelHandlerContext, read message: Any)
}

extension InboundChannelHandler {
    public func channel(active context: ChannelHandlerContext) {
        context.fireChannelActive()
    }
    
    public func channel(inactive context: ChannelHandlerContext) {
        context.fireChannelInactive()
    }
    
    public func channel(_ context: ChannelHandlerContext, error: Error) {
        context.fireErrorCaught(error)
    }
    
    public func channel(_ context: ChannelHandlerContext, read message: Any) {
        context.fireChannelRead(message)
    }
}

public protocol OutboundChannelHandler: ChannelHandler {
    func channel(connect    context: ChannelHandlerContext, to host: String, port: Int)
    func channel(disconnect context: ChannelHandlerContext)
    
    func channel(_ context: ChannelHandlerContext, write message: Any)
}

extension OutboundChannelHandler {
    public func channel(connect context: ChannelHandlerContext, to host: String, port: Int) {
        context.connect(to: host, port: port)
    }
    
    public func channel(disconnect context: ChannelHandlerContext) {
        context.disconnect()
    }
    
    public func channel(_ context: ChannelHandlerContext, write message: Any) {
        context.write(message)
    }
}

public typealias DuplexChannelHandler = InboundChannelHandler & OutboundChannelHandler
