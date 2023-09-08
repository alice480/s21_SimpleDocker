#include <stdio.h>
#include <fcgi_stdio.h>

int main(void) {

  while(FCGI_Accept() >= 0) {
    printf("Content-type: text/html\r\nStatus: 200 OK\r\n\r\n<h1>Hello World!</h1>");
  }

  return 0;
}
