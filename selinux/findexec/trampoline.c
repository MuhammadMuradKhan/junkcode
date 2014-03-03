#include <stdio.h>
int main(int ac, char **av) {
        int localfn(int a) {
                return a+ac;
        }
        int (*fptr)(int) = localfn;

        printf("%d\n", fptr(-1));
        return 0;
}
