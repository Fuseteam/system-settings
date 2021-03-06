/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "polkitlistener.h"
#include <iostream>
#include <unistd.h>

#define SUCCESS         0
#define CANNOT_RUN      1
#define CANNOT_REGISTER 2
#define CANNOT_INIT     3
#define BAD_PPID        4

int main()
{
    UssPolkitListener *polkitListener = uss_polkit_listener_new();
    if (polkitListener == nullptr)
        return CANNOT_INIT;

    // Get pid
    pid_t ppid = getppid();
    if (ppid == 1) {
        uss_polkit_listener_free(polkitListener);
        return BAD_PPID;
    }
    uss_polkit_listener_set_pid(polkitListener, ppid);

    // Read password
    std::string password;
    std::getline(std::cin, password);
    uss_polkit_listener_set_password(polkitListener, password.c_str());

    if (!uss_polkit_listener_register(polkitListener)) {
        uss_polkit_listener_free(polkitListener);
        return CANNOT_REGISTER;
    }

    // Tell caller that we're ready to start
    std::cout << "ready" << std::endl;

    if (!uss_polkit_listener_run(polkitListener)) {
        uss_polkit_listener_free(polkitListener);
        return CANNOT_RUN;
    }

    uss_polkit_listener_free(polkitListener);
    return SUCCESS;
}
