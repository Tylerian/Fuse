//
//  fs_byte_buffer_read_bytes.c
//  Fuse
//
//  Created by Jairo Tylera on 20/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_bytes(fs_byte_buffer *buffer, fs_byte *out, uint32_t length)
{
    /* calculate output size */
    int out_length = sizeof(out) / sizeof(fs_byte);
    
    /* it can't be less than
     * requested read length */
    if (out_length < length)
    {
        return FS_ERR_OOB;
    }
    
    /* src must be readable */
    int is_readable = fs_byte_buffer_is_readable_by(buffer, length);
    
    if (is_readable == FS_NO)
    {
        return FS_ERR_OOB;
    }
    
    /* copy src into dst
     * by reader_index */
    memcpy(out, buffer->heap + buffer->reader_index, length);
    
    /* increase reader_index */
    buffer->reader_index += length;
    
    return FS_OKAY;
}
