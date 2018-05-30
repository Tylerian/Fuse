//
//  ChannelPipeline.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public protocol ChannelPipeline: class {
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    func add(handler: ChannelHandler, named name: String)
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    func add(handler: ChannelHandler, named name: String, after  existing: String)
    
    /// Add a `ChannelHandler` to the `ChannelPipeline`.
    func add(handler: ChannelHandler, named name: String, before existing: String)
    
    func fire(channel: Channel, read  message: Any)
    func fire(channel: Channel, write message: Any)
    
    func fire(channel: Channel, writabilityChanged writable: Bool)
}

public final class DefaultChannelPipeline: ChannelPipeline {
    
    private let channel: Channel
    
    private let head: ChannelHandler
    private let tail: ChannelHandler
    
    public func add(handler: ChannelHandler, named name: String) {
        
    }
    
    public func add(handler: ChannelHandler, named name: String, after existing: String) {
        
    }
    
    public func add(handler: ChannelHandler, named name: String, before existing: String) {
        
    }
}
