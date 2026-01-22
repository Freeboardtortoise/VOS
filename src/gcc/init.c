//    the init program for tortoiseLinux
//    Copyright (C) 2025  Freeboardtortoise
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.


// init.c - bootstrap init for TortoiseLinux
#include <unistd.h>
#include <sys/mount.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/resource.h>

void increase_stack() {
    struct rlimit rl;
    rl.rlim_cur = 64 * 1024 * 1024; // 64 MB
    rl.rlim_max = 64 * 1024 * 1024; // hard limit
    if (setrlimit(RLIMIT_STACK, &rl) != 0) {
        perror("Failed to increase stack size");
    } else {
        printf("Stack size increased to 64 MB\n");
    }
}
void redirect_stdio() {
    // Open /dev/console for stdin/stdout/stderr
    int fd = open("/dev/console", O_RDWR);
    if (fd < 0) {
        perror("Failed to open /dev/console");
        exit(1);
    }
    dup2(fd, 0); // stdin
    dup2(fd, 1); // stdout
    dup2(fd, 2); // stderr
    if (fd > 2) close(fd);
}

int main() {
    printf("init starting...\n");
    printf("changing stack size \n");
    increase_stack();

    

    // Mount virtual filesystems
    mount("proc", "/proc", "proc", 0, NULL);
    mount("sysfs", "/sys", "sysfs", 0, NULL);
    mount("devtmpfs", "/dev", "devtmpfs", 0, NULL);
    mount("tmpfs", "/tmp", "tmpfs", 0, "mode=1777");

    // Run mdev to populate /dev
    pid_t pid = fork();
    if (pid == 0) {
        char *args[] = { "/sbin/mdev", "-s", NULL };
        execv(args[0], args);
        perror("execv /sbin/mdev failed");
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        printf("mdev completed with status %d\n", status);
    } else {
        perror("fork failed");
        exit(1);
    }

    // Wait until /dev/console exists
    while (access("/dev/console", F_OK) != 0) {
        printf("Waiting for /dev/console...\n");
        sleep(1);
    }
    // Redirect stdin/stdout/stderr to /dev/console
    redirect_stdio();


    printf("Launching Vinit...\n");

    // Fork and exec Vinit
    pid = fork();
    if (pid == 0) {
        char *vinit_args[] = { "/sbin/vinit", NULL };
        execv(vinit_args[0], vinit_args);
        perror("execv /sbin/vinit failed");
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        printf("Vinit exited with status %d\n", status);
    }

    // If Vinit exits, drop into /bin/sh for debugging
    printf("Vinit finished, dropping into /bin/sh for debugging...\n");
    pid = fork();
    if (pid == 0) {
        char *vinit_args[] = { "/bin/sh", NULL };
        execv(vinit_args[0], vinit_args);
        perror("execv /bin/sh failed");
        exit(1);
    } else if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        printf("Vinit exited with status %d\n", status);
    }

    // If shell fails, panic and loop
    printf("execv /bin/sh failed");
    while (1) sleep(1);

    return 0;
}
