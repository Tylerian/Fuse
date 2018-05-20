//
//  fs_byte_buffer_free.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_free(fs_byte_buffer* buffer)
{
    /* only do anything if heap
     * hasn't been previously freed */
    if (buffer->heap != NULL)
    {
        /* First clear the memory */
        for (int i = 0; i < buffer->writer_index; i++)
        {
            buffer->heap[i] = 0;
        }
        
        /* Free the memory */
        free(buffer->heap);
        
        /* Reset members to make debugging easier */
        buffer->heap = NULL;
        
        buffer->reader_mark = 0;
        buffer->writer_mark = 0;
        
        buffer->reader_index = 0;
        buffer->writer_index = 0;
    }
    
    return FS_OKAY;
}
