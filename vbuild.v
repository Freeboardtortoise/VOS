module main

import os

fn complile_v_file(file_path string, out string, st bool) {
	if st == true {
		os.system("v -prod ${file_path} -cc gcc '-static -static-libgcc' -o ${out}")
	} else {
		os.system("v -prod ${file_path} -o ${out}")
	}
}

fn main() {
	vbuildfile := "vbuildfile"


	// read he file into a var
	commands := os.read_lines(vbuildfile) or {panic("panic reading 'vbuild' file")}
	for command in commands {
		print(command)
		ncommand := command.split(" ")
		if ncommand[0] == "compile"  {
			if ncommand[1] == "V" {
				file_path := ncommand[2]
				file_output := ncommand[3]
				st := ncommand[4] == "static"
				complile_v_file(file_path, file_output, st)
			}
		} else if ncommand[0] == "run" {
			os.system("${ncommand[1..].join(" ")}")
		}
	}
}