#include <string.h>

int main(int ac, char **av)
{
        char buf[10];
        strcpy(buf, av[1]);
        return buf[5];
}
