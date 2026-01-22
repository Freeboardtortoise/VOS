//    the login for tortoiseLinux
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
#include <pwd.h>


#include <sodium.h>
#include <string>

std::string hash_password(const std::string& password) {
    if (sodium_init() < 0) {
        throw std::runtime_error("Sodium init failed");
    }

    char hash[crypto_pwhash_STRBYTES];

    if (crypto_pwhash_str(
            hash,
            password.c_str(),
            password.size(),
            crypto_pwhash_OPSLIMIT_INTERACTIVE,
            crypto_pwhash_MEMLIMIT_INTERACTIVE
        ) != 0)
    {
        throw std::runtime_error("Hash failed (out of memory)");
    }

    return std::string(hash);
}

int main() {
  // wiping the /etc/userinfo file
  std::ofstream theofile("/etc/userinfo");
  theofile.close();

  system("clear");
  std::cout << "wellcome to VimOS \n\n" << std::endl;
  std::string username;
  std::string password;
  password = hash_password(password);
  bool loggedIn = false;

    // finding the usernames and passwords in the /etc/passwd file
  std::cout << "checking in etc/passwd file" << std::endl;
  while (loggedIn == false) {
    std::cout << " VimOS login username: ";
    std::cin >> username;
    std::cout << "password: ";
    std::cin >> password;

    std::ifstream file("/etc/passwd");
    std::string line;
    while (std::getline(file, line)) {
      if (line.find(username) != std::string::npos) {
        if (line.find(password) != std::string::npos) {
          std::cout << "login successful" << std::endl;
          loggedIn = true;
        } else {
          std::cout << "wrong password" << std::endl;
        }
      }
    }
    if (loggedIn == true) {
      std::cout << "login successful" << std::endl;
      // executing the init file
      system("/bin/login_init");

    } else {
      std::cout << "user not found" << std::endl;
      std::cout << "do you wish to create a new user? (y/n)" << std::endl;
      std::string answere;
      std::cin >> answere;
      if (answere == "y") {
        std::cout << "username: ";
        std::cin >> username;
        std::cout << "password: ";
        std::cin >> password;
        std::cout << "creating a new user" << std::endl;
        password = hash_password(password);
        // creating a new user
        // adding the user to the /etc/passwd file
        std::ofstream file("/etc/passwd");
        file << username << ":" << password << std::endl;
        std::cout << "login successful" << std::endl;
        // executing the init file
        system("/bin/login_init");
        loggedIn = true;
      }
      else {
        std::cout << "incorrect... retry" << std::endl;
      }
    }
  }

  // format is as follows
  // username:password
  // username:password
  // in the file
  // if the username is found, check if the password is correct
  // if the password is correct, print "login successful"
  // if the password is incorrect, print "wrong password"
  // if the username is not found, print "user not found"
  //
  // adding the info to the /etc/userinfo file
  std::ofstream ofile("/etc/userinfo", std::ios::app);
  ofile << "username: " << username << std::endl;
  ofile << "password: " << password << std::endl;
  system("/bin/login_init");

  

  return 0;
}
