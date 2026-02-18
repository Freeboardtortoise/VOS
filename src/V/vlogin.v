module main

import os

import time

import freeboardtortoise.vcurses
import crypto.sha256
import encoding.hex

fn hash(input string) string{
    hash := sha256.sum(input.bytes())
    return hex.encode(hash)
}

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
			//password functionality
			screen.addstr("USERNAME: ${username}", vcurses.Pos{0,5}, ["",""])
			screen.addstr("PASSWORD: ", vcurses.Pos{0,6}, ["",""])
			screen.write("*".repeat(password.len)+" ".repeat(1), ["",""])
			key := screen.getch()
			if key == "\n" || key == "\r" {
				logged_in = true
			} else if key == "\b" || key == "\177" {
				if password.len-1 > -1 {
					password = password[..password.len-1]
					screen.addstr(" ",vcurses.Pos{10+password.len-1,5}, ["",""])
				}
			} else {
				password = password + key
				screen.write("*", ["",""])
			}
		}
	}
	
	print("checking things go here")
	vcurses.uninit(screen)


	// opening and reading the password file
	passwords_file := os.read_lines("/etc/pswds.txt") or {panic('error reading the pswds.txt file')}
	desired_password := passwords_file[0]
	password = hash(password)

	if desired_password == password {
		println("seccessfully signed in... well done")
	} else {
		println("incorrect password")
		println("hanging")
		for true {
			time.sleep(1)
			}
	}
}
