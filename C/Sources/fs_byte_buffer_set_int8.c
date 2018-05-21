//
//  fs_byte_buffer_set_int8.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_set_int8(fs_byte_buffer_t *buffer, uint32_t offset, int8_t value)
{
    if (fs_byte_buffer_is_writable_by_length_at_offset(buffer, sizeof(int8_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    buffer->heap[offset] = (uint8_t) value;
    
    return FS_OKAY;
}
