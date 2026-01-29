module main

import os
import term
import time
// import C

// C interop declarations ──────────────────────────────────────────────

#flag linux -lutil   // sometimes needed for openpty/forkpty
#include <pty.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <unistd.h>

fn C.openpty(amaster &int, aslave &int, name &char, termp &C.termios, winp &C.winsize) int
fn C.forkpty(amaster &int, name &char, termp &C.termios, winp &C.winsize) int
fn C.login_tty(fd int) int
fn C.ioctl(fd int, request u64, arg voidptr) int

struct C.winsize {
mut:
    ws_row    u16
    ws_col    u16
    ws_xpixel u16
    ws_ypixel u16
}

// ──────────────────────────────────────────────────────────────────────

const (
    buf_size = 8192
)

// run_interactive_command starts cmd + args in a pty, forwards stdin → pty,
// reads pty output → stdout (with optional \n → \r\n conversion)
// Blocks until child exits.
fn run_interactive_command(cmd string, args []string) ! {
    mut master_fd := 0

    mut ws := C.winsize{
        ws_row:    u16(term.get_terminal_height() or { 24 })
        ws_col:    u16(term.get_terminal_width() or { 80 })
        ws_xpixel: 0
        ws_ypixel: 0
    }

    // Try forkpty first (convenience function), fallback to openpty+fork
    pid := C.forkpty(&master_fd, unsafe { nil }, unsafe { nil }, &ws)
    if pid < 0 {
        // fallback path — openpty + manual fork
        mut slave_fd := 0
        if C.openpty(&master_fd, &slave_fd, unsafe { nil }, unsafe { nil }, &ws) < 0 {
            return error('openpty failed')
        }
        child_pid := unsafe { C.fork() }
        if child_pid < 0 {
            return error('fork failed')
        }
        if child_pid == 0 {
            // child
            C.close(master_fd)
            C.setsid()
            if C.login_tty(slave_fd) < 0 {
                os.exit(1)
            }
            C.close(slave_fd)
            goto exec
        }
        // parent continues below
        pid = child_pid
        C.close(slave_fd)
    }

    if pid == 0 {
    exec:
        // ──────── child process ────────
        os.setenv('TERM', 'xterm-256color', true) or { } // adjust as needed
        // os.setenv('LANG', 'en_US.UTF-8', true) or {}

        mut argv := []&char{len: args.len + 2, init: unsafe { nil }}
        argv[0] = cmd.str
        for i, arg in args {
            argv[i + 1] = arg.str
        }
        argv[args.len + 1] = unsafe { nil }

        C.execvp(cmd.str, argv.data)
        println('execvp failed: ${os.get_error_msg()}')
        os.exit(127)
    }

    // ──────── parent (your emulator) ────────
    defer {
        os.close(master_fd) or { }
    }

    // Make sure we're in raw mode ourselves (you probably already are)
    // term.enable_raw_mode() is usually called earlier

    mut buf := [buf_size]u8{}

    for {
        // Read from pty (child output)
        n := os.read(master_fd, mut buf) or { -1 }
        if n <= 0 {
            break
        }

        chunk := buf[0..n]

        // ─── Here is where you normally do \n → \r\n conversion ───
        // Option 1: simple (good enough for most cases)
        s := chunk.bytestr().replace('\n', '\r\n')

        // Option 2: zero-allocation streaming write (faster for large output)
        // for i := 0; i < n; {
        //     if buf[i] == `\n` {
        //         os.write(1, [`\r`, `\n`]) or {}
        //         i++
        //     } else {
        //         j := i
        //         for j < n && buf[j] != `\n` { j++ }
        //         os.write(1, buf[i..j]) or {}
        //         i = j
        //     }
        // }

        os.write(1, s.bytes()) or { }   // write to real stdout
        // If using vcurses → feed it here instead of os.write(1, ...)
    }

    // Wait for child to avoid zombies
    mut status := 0
    C.waitpid(pid, &status, 0)
}

// ──────────────────────────────────────────────────────────────────────

fn main() {
    if os.args.len < 2 {
        println('Usage: ${os.args[0]} <command> [args...]')
        println('Example:')
        println('  ${os.args[0]} vim')
        println('  ${os.args[0]} ranger')
        println('  ${os.args[0]} bash')
        return
    }

    cmd := os.args[1]
    args := os.args[2..]

    println('Starting ${cmd} in PTY... (press Ctrl+C / :q in vim etc. to exit)')

    // Usually you already did this earlier in your real program
    term.enable_raw_mode() or { panic('cannot enable raw mode') }
    defer { term.disable_raw_mode() or { } }

    run_interactive_command(cmd, args) or {
        eprintln('Error: ${err}')
        return
    }
}