//
//  ChannelStream.swift
//  fuse
//
//  Created by Jairo Tylera on 22/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

internal class ChannelStream: NSObject {
    
    fileprivate let input: InputStream
    fileprivate let output: OutputStream
    fileprivate let kDefaultBufferSize = 1024
    
    fileprivate var buffer: [UInt8]
    fileprivate var delegate: ChannelStreamDelegate?
    
    internal init(host: String, port: Int)
    {
        var a: InputStream?
        var b: OutputStream?
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &a, outputStream: &b)
        
        guard let input = a, let output = b else {
            fatalError("Error while attempting to get streams for host: \(host) and port: \(port)")
        }
        
        self.input  = input
        self.output = output
        self.buffer = [UInt8](repeating: 0, count: kDefaultBufferSize)
    }
    
    internal func open() {
        self.input.schedule(in: .current, forMode: .defaultRunLoopMode)
        self.output.schedule(in: .current, forMode: .defaultRunLoopMode)
        
        self.input.open()
        self.output.open()
    }
    
    internal func close() {
        self.input.close()
        self.input.close()
        
        self.input.remove(from: .current, forMode: .defaultRunLoopMode)
        self.input.remove(from: .current, forMode: .defaultRunLoopMode)
    }
}

extension ChannelStream: StreamDelegate {
    func stream(_ stream: Stream, handle event: Stream.Event) {
        print("stream(_ stream: \(stream), handle event: \(event)")
        
        switch (stream, event) {
        case (self.input, .openCompleted):
            self.delegate?.stream(opened: self)
            break
        case (self.input, .errorOccurred):
            if let error = stream.streamError {
                self.delegate?.stream(self, hasCaughtError: error)
            }
            break
        case (self.input, .endEncountered):
            self.delegate?.stream(closed: self)
            break
        case (self.input, .hasBytesAvailable):
            let available = self.input.read(&self.buffer, maxLength: kDefaultBufferSize)
            self.delegate?.stream(self, hasBytesAvailable: self.buffer[0 ..< available])
            break
        default:
            break
        }
    }
}

internal protocol ChannelStreamDelegate: class {
    func stream(opened stream: ChannelStream)
    func stream(closed stream: ChannelStream)
    
    func stream(_ stream: ChannelStream, hasCaughtError error: Error)
    func stream(_ stream: ChannelStream, hasBytesAvailable bytes: ArraySlice<UInt8>)
    func stream(_ stream: ChannelStream, hasSpaceAvailable length: Int)
}
