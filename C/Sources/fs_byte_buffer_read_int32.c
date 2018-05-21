//
//  fs_byte_buffer_read_int32.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_read_int32_be(fs_byte_buffer_t *buffer, int32_t *out)
{
    /* get current reader pos */
    int offset = buffer->reader_index;
    
    int result = fs_byte_buffer_get_int32_be(buffer, offset, out);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 4 */
        buffer->reader_index += sizeof(int32_t);
    }
    
    return result;
}

int fs_byte_buffer_read_int32_le(fs_byte_buffer_t *buffer, int32_t *out)
{
    /* get current reader pos */
    int offset = buffer->reader_index;
    
    int result = fs_byte_buffer_get_int32_le(buffer, offset, out);
    
    if (result == FS_OKAY)
    {
        /* increase reader pos by 4 */
        buffer->reader_index += sizeof(int32_t);
    }
    
    return result;
}
