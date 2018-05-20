//
//  fs_byte_buffer_copy.c
//  Fuse
//
//  Created by Jairo Tylera on 20/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse_private.h>

int fs_byte_buffer_copy(fs_byte_buffer *a, fs_byte_buffer *b)
{
    if (b->heap != NULL)
    {
        fs_byte_buffer_free(b);
    }
    
    fs_byte_buffer_init(b, a->capacity);
    
    memcpy(b->heap, a->heap, sizeof(a->heap));
    
    return FS_OKAY;
}
