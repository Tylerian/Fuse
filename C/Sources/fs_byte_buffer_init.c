//
//  fs_byte_buffer.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_init(fs_byte_buffer* buffer, uint32_t capacity)
{
    /* allocate memory */
    buffer->heap = OPT_CAST(fs_byte) malloc(capacity);
    
    if (buffer->heap == NULL)
    {
        return FS_ERR_OOM;
    }
    
    /* clear allocated memory */
    for (int i = 0; i < capacity; i++)
    {
        buffer->heap[i] = 0;
    }
    
    /* Set marks to zero */
    buffer->reader_mark = 0;
    buffer->writer_mark = 0;
    
    /* Set indices to zero */
    buffer->reader_index = 0;
    buffer->writer_index = 0;
    
    return FS_OKAY;
}
