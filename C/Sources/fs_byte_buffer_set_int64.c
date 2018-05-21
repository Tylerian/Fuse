//
//  fs_byte_buffer_set_int64.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_set_int64_be(fs_byte_buffer_t *buffer, uint32_t offset, int64_t value)
{
    if (fs_byte_buffer_is_writable_by_length_at_offset(buffer, sizeof(int64_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    buffer->heap[offset]     = (uint8_t) (value >> 56);
    buffer->heap[offset + 1] = (uint8_t) (value >> 48);
    buffer->heap[offset + 2] = (uint8_t) (value >> 40);
    buffer->heap[offset + 3] = (uint8_t) (value >> 32);
    buffer->heap[offset + 4] = (uint8_t) (value >> 24);
    buffer->heap[offset + 5] = (uint8_t) (value >> 16);
    buffer->heap[offset + 6] = (uint8_t) (value >>  8);
    buffer->heap[offset + 7] = (uint8_t) (value);
    
    return FS_OKAY;
}

int fs_byte_buffer_set_int64_le(fs_byte_buffer_t *buffer, uint32_t offset, int64_t value)
{
    if (fs_byte_buffer_is_writable_by_length_at_offset(buffer, sizeof(int64_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    buffer->heap[offset + 7] = (uint8_t) (value >> 56);
    buffer->heap[offset + 6] = (uint8_t) (value >> 48);
    buffer->heap[offset + 5] = (uint8_t) (value >> 40);
    buffer->heap[offset + 4] = (uint8_t) (value >> 32);
    buffer->heap[offset + 3] = (uint8_t) (value >> 24);
    buffer->heap[offset + 2] = (uint8_t) (value >> 16);
    buffer->heap[offset + 1] = (uint8_t) (value >>  8);
    buffer->heap[offset]     = (uint8_t) (value);
    
    return FS_OKAY;
}
