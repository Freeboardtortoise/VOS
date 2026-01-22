
#include <termios.h>
#include <unistd.h>

static struct termios orig;

void raw_on() {
    tcgetattr(0, &orig);
    struct termios raw = orig;
    raw.c_lflag &= ~(ICANON | ECHO);
    raw.c_iflag &= ~(IXON | ICRNL);
    raw.c_oflag &= ~(OPOST);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;
    tcsetattr(0, TCSANOW, &raw);
}

void raw_off() {
    tcsetattr(0, TCSANOW, &orig);
}

