//
//  fs_byte_buffer_read.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_read_int8(fs_byte_buffer_t *buffer, int8_t *out)
{
    /* get current reader pos */
    int offset = buffer->reader_index;
    
    int result = fs_byte_buffer_get_int8(buffer, offset, out);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 1 */
        buffer->reader_index += sizeof(int8_t);
    }
    
    return result;
}
