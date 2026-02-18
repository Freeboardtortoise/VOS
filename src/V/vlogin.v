module main

import os

import time

import freeboardtortoise.vcurses

fn main() {
	mut screen := vcurses.initialise()
	defer {
		vcurses.uninit(screen)
	}
	mut logged_in := false;
	mut username := ""
	mut password := ""
	mut on_username := true
	for logged_in == false {
		screen.addstr("Velocity Operating System", vcurses.Pos{0,0},["",""])
		screen.addstr("LOGIN", vcurses.Pos{0,1}, ["","","bold"])
		if on_username {
			screen.addstr("USERNAME: ", vcurses.Pos{0,5}, ["",""])
			screen.write(username, ["",""])
			key := screen.getch()
			if key == "\n" || key == "\r" {
				on_username = false
			} else if key == "\b" || key == "\177" {
				if username.len-1 > -1 {
					username = username[..username.len-1]
					screen.addstr(" ",vcurses.Pos{10+username.len-1,5}, ["",""])
				}
			} else {
				username = username + key
				screen.write(key, ["",""])
			}
		} else {
			logged_in = true
		}
	}
}