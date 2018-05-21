//
//  fs_byte_buffer_is_writable.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_is_writable(fs_byte_buffer_t *buffer)
{
    return (buffer->capacity > buffer->writer_index) ? FS_YES: FS_NO;
}

int fs_byte_buffer_is_writable_by_length(fs_byte_buffer_t *buffer, uint32_t length)
{
    return fs_byte_buffer_is_writable_by_length_at_offset(buffer, length, buffer->writer_index);
}

int fs_byte_buffer_is_writable_by_length_at_offset(fs_byte_buffer_t *buffer, uint32_t length, uint32_t offset)
{
    return (buffer->capacity - offset) >= length ? FS_YES: FS_NO;
}
