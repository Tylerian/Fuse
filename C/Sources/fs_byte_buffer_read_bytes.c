//
//  fs_byte_buffer_read_bytes.c
//  Fuse
//
//  Created by Jairo Tylera on 20/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_read_bytes(fs_byte_buffer_t *buffer, uint32_t length, fs_byte_t *out)
{
    /* get current reader pos */
    int offset = buffer->reader_index;
    
    int result = fs_byte_buffer_get_bytes(buffer, offset, length, out);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by length */
        buffer->reader_index += length;
    }
    
    return result;
}
