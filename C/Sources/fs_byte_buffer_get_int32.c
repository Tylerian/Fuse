//
//  fs_byte_buffer_get_int32.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_get_int32_be(fs_byte_buffer_t *buffer, uint32_t offset, int32_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int32_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int32_t) (
           (int32_t) (buffer->heap[offset])     << 24 |
           (int32_t) (buffer->heap[offset + 1]) << 16 |
           (int32_t) (buffer->heap[offset + 2]) <<  8 |
           (int32_t) (buffer->heap[offset + 3]));
    
    return FS_OKAY;
}

int fs_byte_buffer_get_int32_le(fs_byte_buffer_t *buffer, uint32_t offset, int32_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int32_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int32_t) (
           (int32_t) (buffer->heap[offset + 3]) << 24 |
           (int32_t) (buffer->heap[offset + 2]) << 16 |
           (int32_t) (buffer->heap[offset + 1]) <<  8 |
           (int32_t) (buffer->heap[offset]));
    
    return FS_OKAY;
}
