//
//  fs_byte_buffer_read_int16.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_int16(fs_byte_buffer *buffer, int16_t *out)
{
    if (fs_byte_buffer_is_readable_by(buffer, sizeof(int16_t)) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    *out = (int16_t) (
         (int16_t) (buffer->heap[buffer->reader_index++]) << 8 |
         (int16_t) (buffer->heap[buffer->reader_index++]));
    
    return FS_OKAY;
}
