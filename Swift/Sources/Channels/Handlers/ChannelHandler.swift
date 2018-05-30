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
    func handler(added context: ChannelHandlerContext) {
        // NOOP
    }
    
    func handler(removed context: ChannelHandlerContext) {
        // NOOP
    }
}

public protocol InboundChannelHandler: ChannelHandler {
    func channel(connected context: ChannelHandlerContext)
    func channel(disconnected context: ChannelHandlerContext)
    
    func channel(_ context: ChannelHandlerContext, read message: Any)
}

extension InboundChannelHandler {
    func channel(connected context: ChannelHandlerContext) {
        context.fireChannelConnected()
    }
    
    func channel(disconnected context: ChannelHandlerContext) {
        context.fireChannelDisconnected()
    }
    
    func channel(_ context: ChannelHandlerContext, read message: Any) {
        context.fire(channel: context.channel, read: message)
    }
}

public protocol OutboundChannelHandler: ChannelHandler {
    func channel(_ context: ChannelHandlerContext, write message: Any)
}

extension OutboundChannelHandler {
    func channel(_ context: ChannelHandlerContext, write message: Any) {
        context.fire(channel: context.channel, write: message)
    }
}

public typealias DuplexChannelHandler = InboundChannelHandler & OutboundChannelHandler
