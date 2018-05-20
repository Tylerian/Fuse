//
//  fuse.h
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#ifndef FS_H_
#define FS_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <limits.h>
#include <strings.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Bools */
#define FS_NO  0
#define FS_YES 1

/* Errors */
#define FS_OKAY     0
#define FS_ERR_OOR -1
#define FS_ERR_OOM -2
#define FS_ERR_OOB -3

typedef  int8_t fs_err;
typedef uint8_t fs_byte;

/* error code to char* string */
const char *fs_error_to_string(int code);

/* The fs_byte_buffer structure */
typedef struct {
    fs_byte* heap;
    
    uint32_t capacity;
    
    uint32_t reader_mark;
    uint32_t writer_mark;
    
    uint32_t reader_index;
    uint32_t writer_index;
} fs_byte_buffer;

/* --> init and free bytebuf functions <-- */
int fs_byte_buffer_free(fs_byte_buffer* buffer);
int fs_byte_buffer_init(fs_byte_buffer* buffer, uint32_t capacity);
int fs_byte_buffer_copy(fs_byte_buffer* a, fs_byte_buffer* b);

/* --> Capacity functions <-- */
int fs_byte_buffer_is_readable(fs_byte_buffer* buffer);
int fs_byte_buffer_is_writable(fs_byte_buffer* buffer);
int fs_byte_buffer_set_capacity(fs_byte_buffer* buffer, int32_t capacity);

/* --> Reading functions <-- */
int fs_byte_buffer_read_int8 (fs_byte_buffer* buffer, int8_t  *out);
int fs_byte_buffer_read_int16(fs_byte_buffer* buffer, int16_t *out);
int fs_byte_buffer_read_int32(fs_byte_buffer* buffer, int32_t *out);
int fs_byte_buffer_read_int64(fs_byte_buffer* buffer, int64_t *out);
int fs_byte_buffer_read_bytes(fs_byte_buffer* buffer, fs_byte *out, uint32_t length);

/* --> Writing functions <-- */
int fs_byte_buffer_write_int8 (fs_byte_buffer* buffer, int8_t  value);
int fs_byte_buffer_write_int16(fs_byte_buffer* buffer, int16_t value);
int fs_byte_buffer_write_int32(fs_byte_buffer* buffer, int32_t value);
int fs_byte_buffer_write_int64(fs_byte_buffer* buffer, int64_t value);
int fs_byte_buffer_write_bytes(fs_byte_buffer* buffer, fs_byte *value);
#ifdef __cplusplus
}
#endif

#endif /* FS_H_ */
