//    The shell program for VOS
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
module main

import freeboardtortoise.vcurses
import os

fn run_command(cmd string,args []string) {
    // In a process management library, you would specify 'inherit'
    // The exact V syntax would look something like this, using a builder pattern
    // (Note: this is an illustrative example based on common library designs, check official V docs for exact API)

    /*
    process := os.Cmd{
        path: cmd,
        args: args,
        stdin: os.Stdio.inherit(), // Explicitly inherit parent's stdin
        stdout: os.Stdio.inherit(),
        stderr: os.Stdio.inherit(),
    }
    process.run()
    */
}


struct C.termios {
    c_iflag u32
    c_oflag u32
    c_cflag u32
    c_lflag u32
    c_cc [32]byte
    c_ispeed u32
    c_ospeed u32
}


fn C.tcgetattr(fd int, term &Termios) int
fn C.tcsetattr(fd int, when int, term &Termios) int

const icanon = 0x2
const echo = 0x8
const tcsanow = 0
const ixon = 0x200
const icrnl = 0x100
const opost = 0x1
const vmin = 6
const vtime = 5

fn raw_on() C.termios {
	mut orig := C.termios{}
	C.tcgetattr(0, &orig)

	mut raw := orig
	raw.c_lflag &= ~(icanon | echo)
	raw.c_iflag &= ~(ixon | icrnl)
	raw.c_oflag &= ~opost
	raw.c_cc[vmin] = 1
	raw.c_cc[vtime] = 0

	C.tcsetattr(0, tcsanow, &raw)
	return orig
}

fn raw_off(orig C.termios) {
	C.tcsetattr(0, tcsanow, &orig)
}

fn main() {
	mut thing := raw_on()

	mut screen := vcurses.initialise()
	defer {
		screen.clear()
		vcurses.uninit()
		raw_off(thing)
	} // ensure cleanup

	screen.clear()
	mut buffer := vcurses.Buffer.new('buffer 1')
	mut insert_mode := false
	mut done := false
	// data
	prompt := "Vshel user$ "
	// input data
	start_cursor_y := 5
	mut current_cursor_x := 0
	mut current_cursor_y := start_cursor_y
	current_cursor_y += 1
	current_cursor_x = prompt.len

	mut current_command := ""
	for done == false {
		buffer.set_color_pair('black', 'bright_white')
		buffer.addstr('Wellcome to Vshell', vcurses.Pos{1, 1}, ['bright_white', 'black'])
		buffer.addstr('The shell designed for optimal efficiency', vcurses.Pos{1, 2}, ['bright_white','black'])
		if insert_mode {
			buffer.addstr('mode: __insert__', vcurses.Pos{1,3}, ['bright_white', 'black', 'bold'])
		}
		else {
			buffer.addstr('mode: __normal__', vcurses.Pos{1,3}, ['bright_white', 'black', 'bold'])
		}
		buffer.move_cursor(vcurses.Pos{0,current_cursor_y})
		buffer.write(prompt, ['bright_white', 'black', 'bold'])
		screen.show(buffer)
		key := screen.getch()
		


		// keyboard modes
		if insert_mode == true {
			if key == "\r"  || key ==  "\n" {
				current_cursor_y += 1
				current_cursor_x = prompt.len + 1
				buffer.move_cursor(vcurses.Pos{current_cursor_x, current_cursor_y})
				// doing some shenanigans
				raw_off(thing)
				os.system(current_command)
				thing = raw_on()
				insert_mode = false
				current_command = ""
			} else if key == "\b" || key == "\177" {
				if current_command.len > 0 {
					current_command = current_command[..current_command.len-1]
					buffer.addstr(" ", vcurses.Pos{current_cursor_x,current_cursor_y}, ['bright_white', 'black', 'bold'])
					buffer.move_cursor(vcurses.Pos{current_cursor_x,current_cursor_y})
					current_cursor_x -= 1
				}
				
			} else {
				current_command = current_command + key
				current_cursor_x += 1
				buffer.addstr(key,vcurses.Pos{current_cursor_x, current_cursor_y}, ['bright_white', 'black', 'bold'])
			}
		} else {
			if key == "i"{
				insert_mode = true
				//insert mode data things
			}
			if key == "e" {
				insert_mode = false
			}
			if key == "q" {
				done = true
			}
			if key == "l" {
				buffer.clear()
				current_cursor_y = start_cursor_y
			}
		}
	}
}
