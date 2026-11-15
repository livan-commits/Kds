/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * Kds native simulator service boundary.
 *
 * The desktop KGUI build deliberately does not pretend that KodeOS storage
 * Active Objects, the physical IMU, or the firmware Kody asset player exist.
 * Official KGUI screens remain intact; unavailable services fail explicitly.
 */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "kgui_assets.h"
#include "kgui_tilt.h"
#include "kui_kody.h"
#include "kui_pack.h"

/* The native build has no mounted KodeOS asset pack yet. */
const kui_kody_anim_t *kgui_assets_role(kui_pack_role_t role)
{
    (void)role;
    return NULL;
}

/* No physical motion sensor is present in the desktop build. */
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

/*
 * The firmware Kody player needs the SDK's Lottie/ThorVG and timing services.
 * Until those are ported, report the player as unavailable rather than
 * displaying fabricated animation frames.
 */
lv_obj_t *kui_kody_create(lv_obj_t *parent, uint16_t w, uint16_t h)
{
    (void)parent;
    (void)w;
    (void)h;
    return NULL;
}

bool kui_kody_play(lv_obj_t *k, const kui_kody_anim_t *a, bool loop)
{
    (void)k;
    (void)a;
    (void)loop;
    return false;
}

void kui_kody_stop(lv_obj_t *k)
{
    (void)k;
}

/* Canvas metadata is pure SDK data and is safe to expose on the desktop. */
void kui_pack_role_canvas(kui_pack_role_t role, uint16_t *w, uint16_t *h)
{
    uint16_t width = 0U;
    uint16_t height = 0U;

    switch (role) {
    case KUI_PACK_ROLE_EMPTY:
        width = KUI_PACK_EMPTY_W;
        height = KUI_PACK_EMPTY_H;
        break;
    case KUI_PACK_ROLE_WRITING:
    case KUI_PACK_ROLE_GOODBYE:
        width = KUI_PACK_CARD_W;
        height = KUI_PACK_CARD_H;
        break;
    case KUI_PACK_ROLE_LOADING:
        width = KUI_PACK_LOADING_SIDE;
        height = KUI_PACK_LOADING_SIDE;
        break;
    default:
        break;
    }

    if (NULL != w) {
        *w = width;
    }
    if (NULL != h) {
        *h = height;
    }
}
