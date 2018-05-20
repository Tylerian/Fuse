//
//  fs_byte_buffer_read.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_int8(fs_byte_buffer *buffer, int8_t *out)
{
    if (fs_byte_buffer_is_readable_by(buffer, sizeof(int8_t)) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int8_t) (
        buffer->heap[buffer->reader_index++]);
    
    return FS_OKAY;
}
