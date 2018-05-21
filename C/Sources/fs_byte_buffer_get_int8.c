//
//  fs_byte_buffer_get_int8.c
//  fuse
//
//  Created by Jairo Tylera on 21/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_get_int8(fs_byte_buffer_t *buffer, uint32_t offset, int8_t *out)
{
    if (fs_byte_buffer_is_readable_by_length_at_offset(buffer, sizeof(int8_t), offset) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int8_t) buffer->heap[offset];
    
    return FS_OKAY;
}
