//
//  fs_byte_buffer_write_buffer.c
//  Fuse
//
//  Created by Jairo Tylera on 7/06/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_write_buffer(fs_byte_buffer_t *buffer, fs_byte_buffer_t *in)
{
    /* get current writer pos */
    int offset = buffer->writer_index;
    
    int result = fs_byte_buffer_set_bytes(buffer, offset, in->heap);
    
    if (result == FS_OKAY)
    {
        int length = sizeof(in->heap) / sizeof(fs_byte_t);
        
        /* increase reader pos by length */
        buffer->writer_index += length;
    }
    
    return result;
}
