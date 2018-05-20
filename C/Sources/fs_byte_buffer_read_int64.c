//
//  fs_byte_buffer_read_int64.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_int64(fs_byte_buffer *buffer, int64_t *out)
{
    if (fs_byte_buffer_is_readable_by(buffer, sizeof(int64_t)) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int64_t) (
         (int64_t) (buffer->heap[buffer->reader_index++]) << 56 |
         (int64_t) (buffer->heap[buffer->reader_index++]) << 48 |
         (int64_t) (buffer->heap[buffer->reader_index++]) << 40 |
         (int64_t) (buffer->heap[buffer->reader_index++]) << 32 |
         (int64_t) (buffer->heap[buffer->reader_index++]) << 24 |
         (int64_t) (buffer->heap[buffer->reader_index++]) << 16 |
         (int64_t) (buffer->heap[buffer->reader_index++]) <<  8 |
         (int64_t) (buffer->heap[buffer->reader_index++]));
    
    return FS_OKAY;
}
