//
//  ByteBufferError.swift
//  fuse
//
//  Created by Jairo Tylera on 22/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import Foundation

public enum ByteBufferError: Error {
    case limitReached
    case readError
    case writeError
}

extension ByteBufferError {
    var debugDescription: String {
        switch self {
        case .limitReached:
            return "";
        case .readError:
            return "";
        case .writeError:
            return "";
        }
    }
}
