import os
import net.http

fn findurl(name string, filename string) string{
	lines := os.read_lines(filename) or {panic("error reading file ${filename}")}
	for line in lines {
		if line.split(":::::")[0] == name {
			what_to_return := line.split(":::::")[1]
			return what_to_return
		}
	}
	return ""
}

fn pull(url string) !string {
	resp := http.get(url)!
	filename := os.file_name(url)
	path := os.join_path('/pkgs', filename)
	os.write_file(path, resp.body)!
	return filename
}

fn unpak(filename string) ! {
	archive := os.join_path('/pkgs', filename)
	os.execute('mkdir -p /pkgs/builds/')
	res := os.execute('tar -xzf ' + archive + ' -C /pkgs/builds/')
	if res.exit_code != 0 {
		return error(res.output)
	}
}

fn configure(filename string) {
	os.system('cd /pkgs/builds/${filename.trim('.tar.gz')} && ./configure && make')
}

fn install(filename string) {
	os.system('mkdir -p /pkgs/output/${filename.trim('.tar.gz')}')
	os.system('cd /pkgs/builds/${filename.trim('.tar.gz')} && make install')
	os.system('cp -r /pkgs/output/${filename.trim('.tar.gz')} /')
}

fn main() {
	arg := os.args[1]
	if arg == "install" {
		url := os.args[2]
		filename := pull(findurl(url,"src/otherFiles/etc/vpkg/packages.txt"))!
		unpak(filename)!
		configure(filename)
		install(filename)
	}
}
