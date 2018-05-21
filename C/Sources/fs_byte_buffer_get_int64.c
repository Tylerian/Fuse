//
//  fs_byte_buffer_get_int64.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_get_int64_be(fs_byte_buffer_t *buffer, uint32_t offset, int64_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int64_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int64_t) (
           (int64_t) (buffer->heap[offset])     << 56 |
           (int64_t) (buffer->heap[offset + 1]) << 48 |
           (int64_t) (buffer->heap[offset + 2]) << 40 |
           (int64_t) (buffer->heap[offset + 3]) << 32 |
           (int64_t) (buffer->heap[offset + 4]) << 24 |
           (int64_t) (buffer->heap[offset + 5]) << 16 |
           (int64_t) (buffer->heap[offset + 6]) <<  8 |
           (int64_t) (buffer->heap[offset + 7]));
    
    return FS_OKAY;
}

int fs_byte_buffer_get_int64_le(fs_byte_buffer_t *buffer, uint32_t offset, int64_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int64_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int64_t) (
           (int64_t) (buffer->heap[offset + 7]) << 56 |
           (int64_t) (buffer->heap[offset + 6]) << 48 |
           (int64_t) (buffer->heap[offset + 5]) << 40 |
           (int64_t) (buffer->heap[offset + 4]) << 32 |
           (int64_t) (buffer->heap[offset + 3]) << 24 |
           (int64_t) (buffer->heap[offset + 2]) << 16 |
           (int64_t) (buffer->heap[offset + 1]) <<  8 |
           (int64_t) (buffer->heap[offset]));
    
    return FS_OKAY;
}
