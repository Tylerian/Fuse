//
//  ChannelPipeline.swift
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public protocol ChannelPipeline {
    var channel: Channel
    
    func write(object: AnyObject)
}
