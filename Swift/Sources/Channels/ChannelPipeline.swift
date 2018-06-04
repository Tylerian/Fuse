//
//  ChannelPipeline.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public final class ChannelPipeline {
    
    unowned let channel: Channel
    
    private var head: ChannelHandlerContext?
    private var tail: ChannelHandlerContext?
    
    public init(channel: Channel) {
        self.channel = channel
        self.head    = ChannelHandlerContext(name: HeadChannelHandler.name, channel: channel, handler: HeadChannelHandler())
        self.tail    = ChannelHandlerContext(name: TailChannelHandler.name, channel: channel, handler: TailChannelHandler())
        
    }
}

extension ChannelPipeline {
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    public func add(handler: ChannelHandler, named name: String, first: Bool = false) -> Bool {
        if first {
            return self.add(handler: handler, named: name, before: HeadChannelHandler.name)
        } else {
            return self.add(handler: handler, named: name, after: TailChannelHandler.name)
        }
    }
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    public func add(handler: ChannelHandler, named name: String, after existing: String) -> Bool {
        guard let context = self.find(context: existing) else {
            return false
        }
        
        self.add(context: ChannelHandlerContext(name: name, channel: self.channel, handler: handler), after: context)
        return true
    }
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    public func add(handler: ChannelHandler, named name: String, before existing: String) -> Bool {
        guard let context = self.find(context: existing) else {
            return false
        }
        
        self.add(context: ChannelHandlerContext(name: name, channel: self.channel, handler: handler), before: context)
        return true
    }
}

extension ChannelPipeline {
    private func add(context new: ChannelHandlerContext, after existing: ChannelHandlerContext) {
        let next = existing.next
        new.prev = existing
        new.next = next
        existing.next = new
        next?.prev = new
    }
    
    private func add(context new: ChannelHandlerContext, before existing: ChannelHandlerContext) {
        let prev = existing.prev
        new.prev = prev
        new.next = existing
        existing.prev = new
        prev?.next = new
    }
}

extension ChannelPipeline {
    public func remove(name: String) {
        
    }
    
    public func remove(handler: ChannelHandler) {
        
    }
}

extension ChannelPipeline {
    private func find(context named: String) -> ChannelHandlerContext? {
        var current = self.head?.next
        
        while let context = current, context !== self.tail {
            if context.name == named {
                return context
            } else {
                current = context.next
            }
        }
        
        return nil
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

private final class HeadChannelHandler: OutboundChannelHandler {
    static let name: String = "head_pipeline_handler"
    
    func channel(connect context: ChannelHandlerContext, to host: String, port: Int) {
        context.channel.handle.connect(to: host, port: port)
    }
    
    func channel(disconnect context: ChannelHandlerContext) {
        context.channel.handle.disconnect()
    }
    
    func channel(_ context: ChannelHandlerContext, write message: Any) {
        guard let message = message as? ByteBuffer else {
            print("Error: Message isn't in a byte form. Discarding...")
            return
        }
        
        context.channel.handle.write(message)
    }
}

private final class TailChannelHandler: InboundChannelHandler {
    static let name: String = "tail_pipeline_handler"
    
    func channel(active context: ChannelHandlerContext) {
        // Discard event
    }
    
    func channel(inactive context: ChannelHandlerContext) {
        // Discard event
    }
    
    func channel(_ context: ChannelHandlerContext, error: Error) {
        print("Caught unhandled error: \(error)")
    }
    
    func channel(_ context: ChannelHandlerContext, read message: Any) {
        // Discard event
    }
}
