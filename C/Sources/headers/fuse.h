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

typedef  int8_t fs_err_t;
typedef uint8_t fs_byte_t;

/* error code to char* string */
const char *fs_error_to_string(int code);

/* The fs_byte_buffer structure */
typedef struct {
    fs_byte_t* heap;
    
    uint32_t capacity;
    
    uint32_t reader_mark;
    uint32_t writer_mark;
    
    uint32_t reader_index;
    uint32_t writer_index;
} fs_byte_buffer_t;
    
/* --> memory management functions <-- */
int fs_byte_buffer_free(fs_byte_buffer_t* buffer);
int fs_byte_buffer_init(fs_byte_buffer_t* buffer, uint32_t capacity);
int fs_byte_buffer_copy(fs_byte_buffer_t* dst, fs_byte_buffer_t* src);
int fs_byte_buffer_resize(fs_byte_buffer_t *buffer, uint32_t capacity);

/* --> Capacity functions <-- */
int fs_byte_buffer_is_readable (fs_byte_buffer_t* buffer);
int fs_byte_buffer_is_writable (fs_byte_buffer_t* buffer);

int fs_byte_buffer_is_readable_by_length(fs_byte_buffer_t* buffer, uint32_t length);
int fs_byte_buffer_is_writable_by_length(fs_byte_buffer_t* buffer, uint32_t length);

int fs_byte_buffer_is_readable_by_length_at_offset(fs_byte_buffer_t* buffer, uint32_t length, uint32_t offset);
int fs_byte_buffer_is_writable_by_length_at_offset(fs_byte_buffer_t* buffer, uint32_t length, uint32_t offset);
    
int fs_byte_buffer_set_capacity(fs_byte_buffer_t* buffer, int32_t capacity);

/* --> Marking functions <-- */
    
/* --> Reading functions <-- */
int fs_byte_buffer_get_int8    (fs_byte_buffer_t *buffer, uint32_t offset, int8_t  *out);
int fs_byte_buffer_get_int16_be(fs_byte_buffer_t *buffer, uint32_t offset, int16_t *out);
int fs_byte_buffer_get_int16_le(fs_byte_buffer_t *buffer, uint32_t offset, int16_t *out);
int fs_byte_buffer_get_int32_be(fs_byte_buffer_t *buffer, uint32_t offset, int32_t *out);
int fs_byte_buffer_get_int32_le(fs_byte_buffer_t *buffer, uint32_t offset, int32_t *out);
int fs_byte_buffer_get_int64_be(fs_byte_buffer_t *buffer, uint32_t offset, int64_t *out);
int fs_byte_buffer_get_int64_le(fs_byte_buffer_t *buffer, uint32_t offset, int64_t *out);
int fs_byte_buffer_get_bytes   (fs_byte_buffer_t *buffer, uint32_t offset, uint32_t length, fs_byte_t *out);
int fs_byte_buffer_get_slice   (fs_byte_buffer_t *buffer, uint32_t offset, uint32_t length, fs_byte_buffer_t *out);
    
int fs_byte_buffer_read_int8    (fs_byte_buffer_t *buffer, int8_t  *out);
int fs_byte_buffer_read_int16_be(fs_byte_buffer_t *buffer, int16_t *out);
int fs_byte_buffer_read_int16_le(fs_byte_buffer_t *buffer, int16_t *out);
int fs_byte_buffer_read_int32_be(fs_byte_buffer_t *buffer, int32_t *out);
int fs_byte_buffer_read_int32_le(fs_byte_buffer_t *buffer, int32_t *out);
int fs_byte_buffer_read_int64_be(fs_byte_buffer_t *buffer, int64_t *out);
int fs_byte_buffer_read_int64_le(fs_byte_buffer_t *buffer, int64_t *out);
int fs_byte_buffer_read_bytes   (fs_byte_buffer_t *buffer, uint32_t length, fs_byte_t *out);
int fs_byte_buffer_read_slice   (fs_byte_buffer_t *buffer, uint32_t length, fs_byte_buffer_t *out);

/* --> Writing functions <-- */
int fs_byte_buffer_set_int8    (fs_byte_buffer_t *buffer, uint32_t offset, int8_t  value);
int fs_byte_buffer_set_int16_be(fs_byte_buffer_t *buffer, uint32_t offset, int16_t value);
int fs_byte_buffer_set_int16_le(fs_byte_buffer_t *buffer, uint32_t offset, int16_t value);
int fs_byte_buffer_set_int32_be(fs_byte_buffer_t *buffer, uint32_t offset, int32_t value);
int fs_byte_buffer_set_int32_le(fs_byte_buffer_t *buffer, uint32_t offset, int32_t value);
int fs_byte_buffer_set_int64_be(fs_byte_buffer_t *buffer, uint32_t offset, int64_t value);
int fs_byte_buffer_set_int64_le(fs_byte_buffer_t *buffer, uint32_t offset, int64_t value);
int fs_byte_buffer_set_bytes   (fs_byte_buffer_t *buffer, uint32_t offset, const fs_byte_t *in);

int fs_byte_buffer_write_int8    (fs_byte_buffer_t *buffer, int8_t  value);
int fs_byte_buffer_write_int16_be(fs_byte_buffer_t *buffer, int16_t value);
int fs_byte_buffer_write_int16_le(fs_byte_buffer_t *buffer, int16_t value);
int fs_byte_buffer_write_int32_be(fs_byte_buffer_t *buffer, int32_t value);
int fs_byte_buffer_write_int32_le(fs_byte_buffer_t *buffer, int32_t value);
int fs_byte_buffer_write_int64_be(fs_byte_buffer_t *buffer, int64_t value);
int fs_byte_buffer_write_int64_le(fs_byte_buffer_t *buffer, int64_t value);
int fs_byte_buffer_write_bytes   (fs_byte_buffer_t *buffer, const fs_byte_t *in);
int fs_byte_buffer_write_buffer  (fs_byte_buffer_t *buffer, fs_byte_buffer_t *in);
#ifdef __cplusplus
}
#endif

#endif /* FS_H_ */
