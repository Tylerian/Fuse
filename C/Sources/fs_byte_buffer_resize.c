//
//  fs_byte_buffer_resize.c
//  fuse
//
//  Created by Jairo Tylera on 23/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include "fuse_private.h"

int fs_byte_buffer_resize(fs_byte_buffer_t *buffer, uint32_t capacity)
{
    /* If min required capacity equals threshold
     * just set new buffer capacity to threshold */
    if (capacity == BUFFER_CAPACITY_THRESHOLD)
    {
        buffer->capacity = BUFFER_CAPACITY_THRESHOLD;
    }
    
    /* If over threshold, do not double
     * but just increase by threshold */
    else if (capacity > BUFFER_CAPACITY_THRESHOLD)
    {
        buffer->capacity  = capacity / BUFFER_CAPACITY_THRESHOLD * BUFFER_CAPACITY_THRESHOLD;
        buffer->capacity += BUFFER_CAPACITY_THRESHOLD;
    }
    /* If not over threshold.
     * Double up to 4 MiB, starting from 64 */
    else
    {
        buffer->capacity = 64;
        
        while (buffer->capacity < capacity)
        {
            buffer->capacity <<= 1;
        }
    }
    
    buffer->heap = realloc(buffer->heap, buffer->capacity);
    
    if (buffer->heap == NULL)
    {
        return FS_ERR_OOM;
    }
    
    return FS_OKAY;
}
