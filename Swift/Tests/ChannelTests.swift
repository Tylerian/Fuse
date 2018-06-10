//
//  ChannelTest.swift
//  Fuse
//
//  Created by Jairo Tylera on 31/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import XCTest
@testable import Fuse

class ChannelTests: XCTestCase {
    
    func testChannelBootstrap() {
        let bootstrap: Bootstrap = Bootstrap { channel in
            try channel.pipeline.add(handler: TestChannelHandler(), named: "test")
        }
        
        let channel = try? bootstrap.connect(to: "163.172.34.118", port: 20212)
        
        XCTAssertTrue(channel != nil, "Channel is nil!")
    }
    
    func testChannelPipeline() {
        let channel = Channel(socket: { channel in
            let socket = TCPSocket(queue: channel.pipeline.executor)
                socket.delegate = channel
            return socket
        })
        do {
        try channel.pipeline.add(handler: TestChannelHandler(), named: "test_handler")
        } catch let error {
            print("Error while adding handler to pipeline. \(String(describing: error))")
        }
        channel.pipeline.connect(to: "163.172.34.118", port: 20212)
        
        var i: Int = 0
        repeat { i+=1; Thread.sleep(forTimeInterval: 1) } while i != 10
    }
}

private class TestChannelHandler: DuplexChannelHandler {
    func channel(active context: ChannelHandlerContext) throws {
        print("[\(String(describing: Thread.current.name))] -- ChannelActive")
    }
    
    func channel(inactive context: ChannelHandlerContext) throws {
        print("[\(String(describing: Thread.current.name))] -- ChannelInactive")
    }
}
