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

/* fs_byte_buffer_t constants */
#define BUFFER_CAPACITY_THRESHOLD 1024 * 1024 * 4 // 4 MiB page
    
#ifdef __cplusplus
}
#endif

#endif /* FS_PRIVATE_H_ */
