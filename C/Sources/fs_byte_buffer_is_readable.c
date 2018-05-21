//
//  fs_byte_buffer_is_readable.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_is_readable(fs_byte_buffer_t *buffer)
{
    return (buffer->writer_index > buffer->reader_index) ? FS_YES: FS_NO;
}

int fs_byte_buffer_is_readable_by_length(fs_byte_buffer_t *buffer, uint32_t length)
{
    return fs_byte_buffer_is_readable_by_length_at_offset(buffer, length, buffer->reader_index);
}

int fs_byte_buffer_is_readable_by_length_at_offset(fs_byte_buffer_t *buffer, uint32_t length, uint32_t offset)
{
    return (buffer->writer_index - offset >= length) ? FS_YES: FS_NO;
}
