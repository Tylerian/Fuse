//
//  fs_byte_buffer_get_int16.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_get_int16_be(fs_byte_buffer_t *buffer, uint32_t offset, int16_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int16_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int16_t) (
           (int16_t) (buffer->heap[offset]) << 8 |
           (int16_t) (buffer->heap[offset + 1]));
    
    return FS_OKAY;
}

int fs_byte_buffer_get_int16_le(fs_byte_buffer_t *buffer, uint32_t offset, int16_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int16_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int16_t) (
           (int16_t) (buffer->heap[offset + 1]) << 8 |
           (int16_t) (buffer->heap[offset]));
    
    return FS_OKAY;
}
