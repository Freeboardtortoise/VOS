//    custom whoami for tortoiseLinux
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
#include <fstream>

int main() {
  //getting user from /etc/userinfo
  std::ifstream file("/etc/userinfo");
  std::string line;
  std::getline(file, line); // get the username line

  std::cout << "Hello " << line << std::endl;
  return 0;
}
