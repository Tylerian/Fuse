//
//  ByteBufferEndianness.swift
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public enum ByteBufferEndianness {
    case bigEndian
    case littleEndian
    
    public func transform<T: Numeric>(_ slice: inout Array<T>) -> Array<T> {
        switch (self) {
        case .bigEndian:
            slice.reverse()
            break
        case.littleEndian:
            // NOOP since iOS/OSX is le
            break
        }
        
        return slice
    }
}
