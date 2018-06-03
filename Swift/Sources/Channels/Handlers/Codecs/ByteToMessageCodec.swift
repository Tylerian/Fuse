//
//  ByteToMessageCodec.swift
//  fuse
//
//  Created by Jairo Tylera on 28/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public class ByteToMessageCodec<In, Out>: DuplexChannelHandler {
    private let decoder: ByteToMessageDecoder<Out>!
    private let encoder: MessageToByteEncoder<In>!
    
    public init() {
        self.decoder = _ByteToMessageDecoder(self)
        self.encoder = _MessageToByteEncoder(self)
    }
    
    public func handler(added context: ChannelHandlerContext) {
        self.decoder.handler(added: context)
        self.encoder.handler(added: context)
    }
    
    public func handler(removed context: ChannelHandlerContext) {
        self.decoder.handler(removed: context)
        self.encoder.handler(removed: context)
    }
    
    public func channel(_ context: ChannelHandlerContext, read message: Any) {
        self.decoder.channel(context, read: message)
    }
    
    public func channel(_ context: ChannelHandlerContext, write message: Any) {
        
    }
    
    public func channel(_ context: ChannelHandlerContext, encode message: In, output: ByteBuffer) throws {
        fatalError("func channel(_:encode:output) must be implemented by subclass.")
    }
    
    public func channel(_ context: ChannelHandlerContext, decode bytes: ByteBuffer, output: inout [Out]) throws {
        fatalError("func channel(_:decode:output) must be implemented by subclass.")
    }
    
    private class _ByteToMessageDecoder: ByteToMessageDecoder<Out> {
        unowned let codec: ByteToMessageCodec<In, Out>
        
        private init(codec: ByteToMessageCodec<In, Out>) {
            self.codec = codec
        }
        
        override func channel(_ context: ChannelHandlerContext, decode bytes: ByteBuffer, output: inout [Out]) throws {
            try self.codec.channel(context, decode: bytes, output: &output)
        }
    }
    
    private class _MessageToByteEncoder: MessageToByteEncoder<In> {
        unowned let codec: ByteToMessageCodec<In, Out>
        
        private init(codec: ByteToMessageCodec<In, Out>) {
            self.codec = codec
        }
        
        override func channel(_ context: ChannelHandlerContext, encode message: In, output: ByteBuffer) throws {
            try self.codec.channel(context, encode: message, output: output)
        }
    }
}

public class MessageToByteEncoder<In>: OutboundChannelHandler {
    
    
    public func channel(_ context: ChannelHandlerContext, encode message: In, output: ByteBuffer) throws {
        fatalError("func channel(_:encode:output) must be implemented by subclass.")
    }
}

public class ByteToMessageDecoder<Out>: InboundChannelHandler {
    private var buffer: ByteBuffer
    
    public init() {
        
    }
    
    public func channel(_ context: ChannelHandlerContext, read message: Any) {
        guard let buffer = message as? ByteBuffer else {
            context.fire(channel: context.channel, read: message)
            return
        }
        
        do {
            var output = Array<Out>()
            try self.channel(context, decode: buffer, output: &output)
        } catch {
            
        }
        
    }
    
    public func channel(_ context: ChannelHandlerContext, decode bytes: ByteBuffer, output: inout [Out]) throws {
        fatalError("func channel(_:decode:output) must be implemented by subclass.")
    }
}
