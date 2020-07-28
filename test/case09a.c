#include <stdio.h>
int main() {
    FILE *fp;
    int c;
fp = fopen(__FILE__,"r");
    do {
         c = getc(fp);  // read char
         putchar(c);    // display char
    }
    while(c != EOF);
        fclose(fp);
    return 0;
}
