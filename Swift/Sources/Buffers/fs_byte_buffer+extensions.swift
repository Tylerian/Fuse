//
//  fs_byte_buffer+extensions.swift
//  Fuse
//
//  Created by Jairo Tylera on 20/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

import CFuse

extension fs_byte_buffer {
    internal init() {
        self = fs_byte_buffer(heap: nil, capacity: 0, reader_mark: 0, writer_mark: 0, reader_index: 0, writer_index: 0)
    }
}
