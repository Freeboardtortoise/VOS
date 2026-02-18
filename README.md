# VOS - linux based opperating system for the power user

## What is VOS

VOS is a linux based operating system focused around human efficiency

## What is the philophy behind VOS

productivity comes 1st and it being user friendly comes last
this means that the learning curve is steep but the payoff is large as well

## Who should you use VOS

this opperating system is designed for the power user and the user that wants to get the most out of their interaction with the computer.

## who shouldnt use VOS

The user that just wants to use their computer and wants to be able to do it without pain :) and get to using it as fast as they possibly can.

## some documentation

### requirments

#### packages

- linux system
- qemu-full
- parted
- make
- mkfs
- bash
- gcc
- grub
- grub-install
- git

### vpkg

install a package: `vpkg install <package name>` and the package manager will handle the conversion based on te packag database

### vshell

vshell is a vim-style shell with vim style keybindings:

How to use it:

#### Keybinds

The keybindings are set in the config file located in
`/home/user/.config/vshell/config.json` and the keybindings are defined as such:

```json
{
    "keybinds" : {
        "insert": <key for insert mode>,
        "history": <key for history>,
        "exit":<key to exit>,
        "save": <key to save to file>,
        "clear": <key to clear the screen>,
        "moveup": <key to go up>,
        "movedown": <key to go down in menues>
    },
    "tutorial": false
}
```

#### The tutorial

The tutorial teaches you how to use the keybindings you have set and generaly how the shell works.

### vinit

vinit is the init system for VelcityOS custom writen in `vlang`

#### commands

the config file is located in
`/vinit/vinit.txt`
and the rules are as follows

```text
write <Message>
run <program>
```

so far this is all the vinit program is capable of

### compile.sh

compile.sh is the build systm for velocity OS

#### Command line arguments

`./compie.sh <'serial'/'gui'>`

The serial mode runs the OS in the terminal that you ran it from

The gui mode runs the OS in a separate qemu window
