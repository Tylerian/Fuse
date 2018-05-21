//
//  fs_byte_buffer_get_bytes.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_get_bytes(fs_byte_buffer_t *buffer, uint32_t offset, uint32_t length, fs_byte_t *out)
{
    /* calculate output size */
    int out_length = sizeof(out) / sizeof(fs_byte_t);
    
    /* it can't be less than
     * requested read length */
    if (out_length < length)
    {
        return FS_ERR_OOB;
    }
    
    /* src must be readable */
    int is_readable = fs_byte_buffer_is_readable_by_length_at_offset(buffer, length, offset);
    
    if (is_readable == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    /* copy src into dst
     * by reader_index */
    memcpy(out, buffer->heap + offset, length);
    
    return FS_OKAY;
}
