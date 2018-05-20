#include <fuse_private.h>

static const struct {
    int code;
    const char *msg;
} msgs[] = {
    { FS_OKAY,    "Successful" },
    { FS_ERR_OOB, "Out of boundaries"},
    { FS_ERR_OOM, "Out of heap" },
    { FS_ERR_OOR, "Value out of range" }
};

const char *fs_error_to_string(int code)
{
    int x;
    
    /* scan the lookup table for the given message */
    for (x = 0; x < (int)(sizeof(msgs) / sizeof(msgs[0])); x++)
    {
        if (msgs[x].code == code)
        {
            return msgs[x].msg;
        }
    }
    
    /* generic reply for invalid code */
    return "Invalid error code";
}
