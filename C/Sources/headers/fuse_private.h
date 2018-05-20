//
//  fuse_private.h
//  Fuse
//
//  Created by Jairo Tylera on 19/05/18.
//  Copyright © 2018 Tylerian. All rights reserved.
//

#ifndef FS_PRIVATE_H_
#define FS_PRIVATE_H_

#include "fuse.h"

#ifdef __cplusplus
extern "C" {
/* C++ compilers don't like
 * assigning void * to fs_byte * */
#define OPT_CAST(x)  (x *)
#else
/* C on the other hand doesn't care */
#define OPT_CAST(x)
#endif

/* --> Boundary functions <-- */
int fs_byte_buffer_is_readable_by(fs_byte_buffer* buffer, int length);
int fs_byte_buffer_is_writable_by(fs_byte_buffer* buffer, int length);

#ifdef __cplusplus
}
#endif

#endif /* FS_PRIVATE_H_ */
