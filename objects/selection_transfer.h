/*
 * selection_transfer.c - objects for selection transfer header
 *
 * Copyright © 2019 Uli Schlachter <psychon@znc.in>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

#ifndef AWESOME_OBJECTS_SELECTION_TRANSFER_H
#define AWESOME_OBJECTS_SELECTION_TRANSFER_H

#include <lua.h>
#include <xcb/xcb.h>

void selection_transfer_class_setup(lua_State*);
void selection_transfer_reject(xcb_window_t, xcb_atom_t, xcb_atom_t, xcb_timestamp_t);
void selection_transfer_begin(lua_State*, int, xcb_window_t, xcb_atom_t,
        xcb_atom_t, xcb_atom_t, xcb_timestamp_t);
void selection_transfer_handle_propertynotify(xcb_property_notify_event_t*);

#endif

// vim: filetype=c:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
