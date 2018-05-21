//
//  fs_byte_buffer_write_int32.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_write_int32_be(fs_byte_buffer_t *buffer, int32_t value)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_int32_be(buffer, offset, value);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 4 */
        buffer->writer_index += sizeof(int32_t);
    }
    
    return result;
}

int fs_byte_buffer_write_int32_le(fs_byte_buffer_t *buffer, int32_t value)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_int32_le(buffer, offset, value);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 4 */
        buffer->writer_index += sizeof(int32_t);
    }
    
    return result;
}
