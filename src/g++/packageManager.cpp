
//    the package manager for tortoiseLinux
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

#include <iostream>

int main(int argc, char* argv[]) {
  if (argv[1] == "install") {
    std::string url = argv[2];
    std::string cmd = "wget " + url + " -O /tmp/package.tar.gz";
    system(cmd.c_str());
    system("tar -xzf /tmp/mypackage.tar.gz -C /tmp/");
    system("cp /tmp/mypackage/bin/* /bin/ && cp /tmp/mypackage/lib/* /lib/");
  }

  return 0;
}
