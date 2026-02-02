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

import json

struct Keybinds {
pub:
	insert string = "i"
	history string = "h"
	exit string = "q"
	save string = "s"
	clear string = "l"
}

struct Config {
	keybinds Keybinds
	tutorial bool
}


fn load_config(filen string) Config {
	// file := os.open(filen) or {panic("error  opening config file")}
	file_contents := os.read_file(filen) or {panic("error oppening file")}
	cfg := json.decode(Config, file_contents) or {panic("error in decode of json config file")}
	// insert := cfg[name]["insert"]
	//history := cfg[name]["history"]
	//exit := cfg[name]["exit"]
	//save := cfg[name]["save"]
	//clear := cfg[name]["clear"]
	//return Config{insert: insert,history:history,exit:exit,save:save,clear:clear}
	return cfg
}


fn show_slide(mut screen vcurses.Screen, text string, attribs []string) vcurses.Screen{
	mut buffer := vcurses.Buffer.new("tempBuffer")
	buffer.addstr(text, vcurses.Pos{0,0}, attribs)
	screen.show(buffer)
	_ := screen.getch()
	screen.clear()
	screen.refresh()
	return screen
	
}

fn main() {

	cfg := load_config("src/V/config.json")
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

	if cfg.tutorial == true {
		// tutorial instructions
		show_slide(mut screen, "wellcome to vshell.... the shell designed for optimal efficiency... this is the tutorial for new users... press any key to continue to the next slide at any point", ["",""])
		// modes
		show_slide(mut screen, "Vshell is mutch like vim in the way that there are modes for instance: \n\r Insert mode \n\r Normal mode", ["",""])
		// keybinds
		buffer.clear()
		show_slide(mut screen, "to enter the insert mode: you must press the ${cfg.keybinds.insert} button", ["",""])
		show_slide(mut screen, "to exit the insert mode: you must run a command and press enter", ["",""])
		show_slide(mut screen, "to clear the screen: press the ${cfg.keybinds.clear} key while in normal mode", ["",""])

		buffer.clear()
		screen.refresh()
		
	}

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
				screen.pause_raw()
				os.system(current_command)
				screen.restart_raw()
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
			if key == cfg.keybinds.insert{
				insert_mode = true
				//insert mode data things
			}
			if key == cfg.keybinds.exit {
				done = true
			}
			if key == cfg.keybinds.clear {
				buffer.clear()
				screen.refresh()
				current_cursor_y = start_cursor_y
			}
		}
	}
}
