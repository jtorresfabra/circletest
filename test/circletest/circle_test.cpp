#include <stdint.h>
#include <stdio.h>

#include <circle/circle.h>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#else
#define EMSCRIPTEN_KEEPALIVE
#endif

int main() { circle::circle_function(); }
