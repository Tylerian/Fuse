//
//  ChannelPipeline.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public final class ChannelPipeline {
    
    private let channel: Channel
    
    private var head: ChannelHandlerContext?
    private var tail: ChannelHandlerContext?
    
    public init(channel: Channel) {
        self.channel = channel
        
        self.head = ChannelHandlerContext(name: "head_pipeline_handler", handler: HeadChannelHandler())
        self.tail = ChannelHandlerContext(name: "tail_pipeline_handler", handler: TailChannelHandler())
    }
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    public func add(handler: ChannelHandler, named name: String) {
        self.add(handler: handler, named: name, after: self.tail?.name)
    }
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    public func add(handler: ChannelHandler, named name: String, after existing: String) {
        
    }
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    public func add(handler: ChannelHandler, named name: String, before existing: String) {
        
    }
}

extension ChannelPipeline: InboundChannelHandlerInvoker {
    public func fireChannelActive() {
        self.head?.triggerChannelActive()
    }
    
    public func fireChannelInactive() {
        self.head?.triggerChannelInactive()
    }
    
    public func fireErrorCaught(_ error: Error) {
        self.head?.triggerErrorCaught(error)
    }
    
    public func fireChannelRead(_ message: Any) {
        self.head?.triggerChannelRead(message)
    }
}

extension ChannelPipeline: OutboundChannelHandlerInvoker {
    public func connect(to host: String, port: Int) {
        self.tail?.connect(to: host, port: port)
    }
    
    public func disconnect() {
        self.tail?.disconnect()
    }
    
    public func write(_ message: Any) {
        self.tail?.write(message)
    }
}

private final class HeadChannelHandler: InboundChannelHandler {
    func channel(active context: ChannelHandlerContext) {
        
    }
    
    func channel(inactive context: ChannelHandlerContext) {
        
    }
    
    func channel(_ context: ChannelHandlerContext, error: Error) {
        
    }
    
    func channel(_ context: ChannelHandlerContext, read message: Any) {
        
    }
}

private final class TailChannelHandler: OutboundChannelHandler {
    func channel(connect context: ChannelHandlerContext, to host: String, port: Int) {
        context.channel.connect(to: host, port: port)
    }
    
    func channel(disconnect context: ChannelHandlerContext) {
        context.channel.disconnect()
    }
    
    func channel(_ context: ChannelHandlerContext, write message: Any) {
        guard let message = message as? ByteBuffer else {
            print("Error: Message isn't in a byte form. Discarding...")
            return
        }
        
        context.channel.write0(message)
    }
}
