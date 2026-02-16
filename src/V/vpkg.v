import os
import net.http

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
	os.system('cp /pkgs/builds/${filename.trim('.tar.gz')}/hello /pkgs/output/${filename.trim('.tar.gz')}')
	os.system('cp /pkgs/output/${filename.trim('.tar.gz')}/hello /bin/')
}

fn main() {
	url := os.args[1]
	filename := pull(url)!
	unpak(filename)!
	configure(filename)
	install(filename)
}
