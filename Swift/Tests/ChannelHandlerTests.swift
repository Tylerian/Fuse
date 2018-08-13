//
//  ChannelHandlerTests.swift
//  Fuse
//
//  Created by Jairo Tylera on 4/06/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import XCTest
import Foundation
@testable import Fuse

class ChannelHandlerTests: XCTestCase {
    var testRunning = true
    
    func testChannelWrite() {
        let channel = Channel(socket: { channel in
            let socket = TCPSocket(queue: channel.pipeline.executor)
                socket.delegate = channel
            return socket
        })
        
        try! channel.pipeline.add(handler: self, named: "xctest_handler")
        
        channel.pipeline.connect(to: "163.172.34.118", port: 20212)
        
        repeat { Thread.sleep(forTimeInterval: 0.25) } while testRunning
    }
}

extension ChannelHandlerTests: DuplexChannelHandler {
    func handler(added context: ChannelHandlerContext) throws {
        print("[XCTEST] -- Handler added!")
    }
    
    func handler(_ context: ChannelHandlerContext, error: Error) throws {
        print("[XCTEST] -- Error caught. \(String(describing: error))")
    }
    
    func channel(active context: ChannelHandlerContext) throws {
        print("[XCTEST] -- Channel active!")
        context.fireChannelActive()
        
        var data: ByteBuffer = UnsafeByteBuffer(capacity: 10)
        _ = data.write(int32: 5, endianness: .bigEndian)
        _ = data.write(bytes: [0xb1, 0xde, 0xb3, 0xb2, 0xb0])
        
        context.write(data)
    }
    
    func channel(inactive context: ChannelHandlerContext) throws {
        print("[XCTEST] -- Channel inactive!")
        context.fireChannelInactive()
        testRunning = false
    }
    
    func channel(_ context: ChannelHandlerContext, read data: Any) throws {
        print("[XCTEST] -- Channel read! -> \(data)")
        context.fireChannelRead(data)
    }
    
    func channel(_ context: ChannelHandlerContext, write data: Any) throws {
        print("[XCTEST] -- Channel write! -> \(data)")
        context.write(data)
    }
}
