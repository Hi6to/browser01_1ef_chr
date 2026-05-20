#include <stdio.h>

int main(void){
  int n  = 1000000;
  int i;
  for(i = 0; i < n; i++){
    printf("I_love_you!\r");
  }
  putchar('\n');
  return 0;
}
