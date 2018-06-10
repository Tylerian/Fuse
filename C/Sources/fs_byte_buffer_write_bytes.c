//
//  fs_byte_buffer_write_bytes.c
//  Fuse
//
//  Created by Jairo Tylera on 20/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_write_bytes(fs_byte_buffer_t *buffer, uint32_t length, const fs_byte_t *in)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_bytes(buffer, length, offset, in);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by length */
        buffer->writer_index += length;
    }
    
    return result;
}
