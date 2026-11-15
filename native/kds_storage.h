/* SPDX-License-Identifier: GPL-3.0-or-later */
#ifndef KDS_STORAGE_H
#define KDS_STORAGE_H
#include <stddef.h>
#include <stdio.h>
/* Persistent host directory representing the virtual Dot SD card. */
int kds_storage_init(void);
const char *kds_storage_root(void);
/* Resolve a relative path safely; rejects absolute paths and ".." traversal. */
int kds_storage_path(const char *relative, char *out, size_t out_size);
FILE *kds_storage_open(const char *relative, const char *mode);
#endif
