module main

import os

fn compile_v_file(file_path string, out string, st bool) {
	if st == true {
		os.system("v -prod ${file_path} -cc gcc -cflags '-static -static-libgcc' -o ${out}")
	} else {
		os.system("v -prod ${file_path} -o ${out}")
	}
}
fn compile_c_file(file_path string, out string, st bool) {
	if st == true {
		os.system("gcc ${file_path} -o ${out} -static")
	} else {
		os.system("gcc ${file_path} -o ${out}")
	}
}
fn compile_cpp_file(file_path string, out string, st bool) {
	if st == true {
		os.system("g++ ${file_path} -o ${out} -static")
	} else {
		os.system("g++ ${file_path} -o ${out}")
	}
}

fn main() {
	vbuildfile := "vbuildfile"
	commandsplitter := " "
	to_run := os.args[1]
	mut currently_running := false


	// read he file into a var
	commands := os.read_lines(vbuildfile) or {panic("panic reading 'vbuild' file")}
	for command in commands {
		mut ncommand_unstripped := command.split(commandsplitter)
		for i in 0 .. ncommand_unstripped.len {
			ncommand_unstripped[i] = ncommand_unstripped[i].trim_space().trim("\t")
		}
		ncommand := ncommand_unstripped

		if currently_running == true {
			if ncommand[0] == "section" {
				currently_running = false
				exit(0)
			}
			println(command)
			if ncommand[0] == "compile"  {
				if ncommand[1] == "V" {
					file_path := ncommand[2]
					file_output := ncommand[3]
					st := ncommand[4] == "static"
					compile_v_file(file_path, file_output, st)
				} else if ncommand[1] == "C" {
					file_path := ncommand[2]
					file_output := ncommand[3]
					st := ncommand[4] == "static"
					compile_c_file(file_path, file_output, st)
				} else if ncommand[1].to_lower() == "cpp" || ncommand[1].to_lower() == "c++"  {
					file_path := ncommand[2]
					file_output := ncommand[3]
					st := ncommand[4] == "static"
					compile_cpp_file(file_path, file_output, st)
				}
			} else if ncommand[0] == "run" {
				os.system("${ncommand[1..].join(commandsplitter)}")
			} else if ncommand[0] == "create" {
				if ncommand[1] == "dir" {
					directory := ncommand[2..].join(commandsplitter)
					os.system("mkdir -p ${directory}")
					println("created DIR ${directory}")
				}
			} else if ncommand[0] == "copy" {
				scr := ncommand[1]
				dest := ncommand[2]
				os.system("cp ${scr} ${dest}")
			} else if ncommand[0] == "write" {
				what_to_write := ncommand[2..].join(commandsplitter)
				level := ncommand[1]
				print("[LOG] [${level}]		${what_to_write}")
			}
		} else {
			if ncommand[0] == "section" {
				if ncommand[1] == to_run + ">>" || ncommand[1] == to_run {
					currently_running = true
				}
			}
		}
	}
}