//
//  ChannelHandlerContext.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public protocol ChannelHandlerContext: class {
    var name: String { get }
    var channel: Channel { get }
    var handler: ChannelHandler { get }
    var pipeline: ChannelPipeline { get }
    
    func fire(channel: Channel, read message: AnyObject)
    func fire(channel: Channel, write message: AnyObject)
    
    func read(_ message: AnyObject)
    
    func write(_ message: AnyObject)
    func write(flushing message: AnyObject)
}

public final class DefaultChannelHandlerContext: ChannelHandlerContext {
    
}
