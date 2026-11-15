/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Kds native simulator HAL boundary.
 *
 * The desktop build has no KodeOS storage Active Object or physical IMU.
 * Keep the official KGUI screens intact while reporting those two services
 * as unavailable; do not fabricate animation data or sensor readings.
 */
#include <stdbool.h>
#include <stddef.h>

#include "kgui_assets.h"
#include "kgui_tilt.h"

const kui_kody_anim_t *kgui_assets_role(kui_pack_role_t role)
{
    (void)role;
    return NULL;
}

void kgui_tilt_run(bool on)
{
    (void)on;
}

bool kgui_tilt_read(float *angle, float *jolt)
{
    if (NULL != angle) {
        *angle = 0.0F;
    }
    if (NULL != jolt) {
        *jolt = 0.0F;
    }
    return false;
}
