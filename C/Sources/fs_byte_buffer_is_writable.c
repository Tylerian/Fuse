//
//  fs_byte_buffer_is_writable.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse.h>

int fs_byte_buffer_is_writable(fs_byte_buffer *buffer)
{
    return (buffer->capacity > buffer->writer_index) ? FS_YES: FS_NO;
}

int fs_byte_buffer_is_writable_by(fs_byte_buffer *buffer, int length)
{
    return (buffer->capacity - buffer->writer_index) >= length ? FS_YES: FS_NO;
}
