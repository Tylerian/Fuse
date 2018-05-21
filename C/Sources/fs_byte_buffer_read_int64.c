//
//  fs_byte_buffer_read_int64.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_int64_be(fs_byte_buffer_t *buffer, int64_t *out)
{
    /* get current reader pos */
    int offset = buffer->reader_index;
    
    int result = fs_byte_buffer_get_int64_be(buffer, offset, out);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 8 */
        buffer->reader_index += sizeof(int64_t);
    }
    
    return result;
}

int fs_byte_buffer_read_int64_le(fs_byte_buffer_t *buffer, int64_t *out)
{
    /* get current reader pos */
    int offset = buffer->reader_index;
    
    int result = fs_byte_buffer_get_int64_le(buffer, offset, out);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 8 */
        buffer->reader_index += sizeof(int64_t);
    }
    
    return result;
}
