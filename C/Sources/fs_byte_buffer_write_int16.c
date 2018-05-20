//
//  fs_byte_buffer_write_int16.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_write_int16(fs_byte_buffer *buffer, int16_t value)
{
    if (fs_byte_buffer_is_writable_by(buffer, sizeof(int16_t)) == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    buffer->heap[buffer->writer_index++] = (uint8_t) (value >> 8);
    buffer->heap[buffer->writer_index++] = (uint8_t) (value);
    
    return FS_OKAY;
}
