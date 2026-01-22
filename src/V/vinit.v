//    the vinit program for VOS (the vim opperating system)
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
import os

fn main() {
	println("Vinit-1.0 starting [OK]")
	mut file := os.open("/vinit/vinit.txt") or {
        print("ERROR: NO VINIT FILE FOUND at /vinit/vinit.txt")
        print("			creating a vinit.txt file and booting normaly")
        mut thing := os.create("/vinit/vinit.json") or {
        	panic("readonly file-system I think")
        }
        thing.close()
        print("    		error averted")	
        os.open("/vinit/vinit.txt") or {
        	panic("never mind")
        }
	}
	file.close()
	init := os.read_file("/vinit/vinit.txt") or {
		panic("I have no idea what the error this is... good luck")
	}

    // file processing
    for line in init.split("\n") {
    	current_line := line.split(" ")
    	if current_line[0] == "write" {
    		mut what_to_print := ""
    		mut current := 0
    		for word in current_line {
    			if current == 0 {
    				// dont do anything here
    			} else {
    				what_to_print = what_to_print + word + " "
    			}
                current++
    		}
    		print(what_to_print)
    		print(" [OK] \n")
    	} else if current_line[0] == "run" {
    		os.flush()
    		mut what_to_print := ""
    		mut current := 0
    		for word in current_line {
    			if current == 0 {
    				// dont do anything here
    			} else {
    				what_to_print = what_to_print + word + " "
    			}
                current++
    		}
    		print("running ${what_to_print}")
    		os.system(what_to_print)
    		print("[ OK ]")
    		print("\n")
    	} else {
    		println("invalid command ${line[0]}")
            println("the valid commands are:")
            println("   write")
            println("   run")
    	}
    }
}