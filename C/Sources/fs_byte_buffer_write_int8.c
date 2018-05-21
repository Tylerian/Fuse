//
//  fs_byte_buffer_write.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_write_int8(fs_byte_buffer_t *buffer, int8_t value)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_int8(buffer, offset, value);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 1 */
        buffer->writer_index += sizeof(int8_t);
    }
    
    return result;
}
