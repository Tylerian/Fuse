//
//  ChannelHandlerInvoker.swift
//  Fuse
//
//  Created by Jairo Tylera on 3/06/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public protocol InboundChannelHandlerInvoker {
    func fireChannelActive()
    func fireChannelInactive()
    
    func fireChannelRead(_ message: Any)
    
    func fireErrorCaught(_ error: Error)
}

public protocol OutboundChannelHandlerInvoker {
    func connect(to host: String, port: Int)
    func disconnect()
    
    func write(_ message: Any)
}

public typealias ChannelHandlerInvoker  = InboundChannelHandlerInvoker & OutboundChannelHandlerInvoker
