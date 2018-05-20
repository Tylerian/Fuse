//
//  fs_byte_buffer_read_int32.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_int32(fs_byte_buffer *buffer, int32_t *out)
{
    if (fs_byte_buffer_is_readable_by(buffer, sizeof(int32_t)) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int32_t) (
         (int32_t) (buffer->heap[buffer->reader_index++]) << 24 |
         (int32_t) (buffer->heap[buffer->reader_index++]) << 16 |
         (int32_t) (buffer->heap[buffer->reader_index++]) <<  8 |
         (int32_t) (buffer->heap[buffer->reader_index++]));
    
    return FS_OKAY;
}
