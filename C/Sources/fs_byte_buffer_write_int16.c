//
//  fs_byte_buffer_write_int16.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_write_int16_be(fs_byte_buffer_t *buffer, int16_t value)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_int16_be(buffer, offset, value);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 2 */
        buffer->writer_index += sizeof(int16_t);
    }
    
    return result;
}

int fs_byte_buffer_write_int16_le(fs_byte_buffer_t *buffer, int16_t value)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_int16_le(buffer, offset, value);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 2 */
        buffer->writer_index += sizeof(int16_t);
    }
    
    return result;
}
