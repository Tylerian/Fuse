//
//  fs_byte_buffer_set_bytes.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_set_bytes(fs_byte_buffer_t *buffer, uint32_t offset, const fs_byte_t *in)
{
    /* calculate input size */
    int length = sizeof(in) / sizeof(fs_byte_t);
    
    /* src must be writable */
    int is_writable = fs_byte_buffer_is_writable_by_length_at_offset(buffer, length, offset);
    
    if (is_writable == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    /* copy `in` into dst by offset */
    if (memcpy(buffer->heap + offset, in, length) == NULL)
    {
        return FS_ERR_OOM;
    }
    
    return FS_OKAY;
}
