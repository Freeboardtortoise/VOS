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
import strings



fn main() {

	mut screen := vcurses.initialise()
	defer {
		screen.clear()
		vcurses.uninit(screen)
	} // ensure cleanup

	screen.clear()
	mut buffer := vcurses.Buffer.new('buffer 1')
	mut insert_mode := false
	mut done := false
	// data
	prompt := "Vshel user$ "
	// input data
	start_cursor_y := buffer.size().height - 2
	output_cursor_y := 5
	mut current_cursor_x := 0
	mut current_cursor_y := start_cursor_y
	current_cursor_x = 1
	last_command_len := 0

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
		buffer.move_cursor(vcurses.Pos{0,start_cursor_y})
		current_cursor_y = start_cursor_y
		buffer.write(":",["blue", "black"])
		screen.show(buffer)
		key := screen.getch()
		


		// keyboard modes
		if insert_mode == true {
			if key == "\r"  || key ==  "\n" {
				buffer.move_cursor(vcurses.Pos{1, start_cursor_y})
				buffer.write("${strings.repeat(' '.bytes()[0], current_command.len + 1)}", ["",""])
				current_cursor_y = output_cursor_y
				current_cursor_x = 1
				screen.move_cursor(vcurses.Pos{current_cursor_x, output_cursor_y})
				screen.write("", ["",""])
				// doing some shenanigans
				os.system(current_command)
				insert_mode = false
				current_command = ""
			} else if key == "\b" || key == "\177" {
				if current_command.len > 0 {
					current_command = current_command[..current_command.len-1]
					buffer.addstr(" ", vcurses.Pos{current_cursor_x,current_cursor_y}, ['', '', 'bold'])
					buffer.move_cursor(vcurses.Pos{current_cursor_x,current_cursor_y})
					current_cursor_x -= 1
				}
				
			} else {
				current_command = current_command + key
				current_cursor_x += 1
				buffer.addstr(key,vcurses.Pos{current_cursor_x, current_cursor_y}, ["blue", "black"])
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
				screen.refresh()
				current_cursor_y = start_cursor_y
			}
		}
	}
}
