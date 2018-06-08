//
//  ChannelEventLoop.swift
//  Fuse
//
//  Created by Jairo Tylera on 5/06/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

internal final class ChannelEventExecutor {
    private let queue: DispatchQueue
    
    internal init() {
        self.queue = DispatchQueue(label: "io.fuse.executor", qos: .utility)
    }
}

