//
//  fs_byte_buffer_is_readable.c
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#include <fuse.h>

int fs_byte_buffer_is_readable(fs_byte_buffer *buffer)
{
    return (buffer->writer_index > buffer->reader_index) ? FS_YES: FS_NO;
}

int fs_byte_buffer_is_readable_by(fs_byte_buffer *buffer, int length)
{
    return (buffer->writer_index - buffer->reader_index >= length) ? FS_YES: FS_NO;
}
