// Aquarius ROM Cartridge C stub for z88dk
// Compile with z88dk, link with custom linker script for Aquarius

#include <stdint.h>

// Aquarius memory map
#define CHRRAM   ((uint8_t*)0x3000)
#define COLRAM   ((uint8_t*)0x3400)
#define RAM      ((uint8_t*)0x3800)
#define BORDER_CHAR_ADDR ((uint8_t*)0x3000)
#define BORDER_COLOR_ADDR ((uint8_t*)0x3400)

// Fill screen with character and color
void clear_screen(uint8_t chr, uint8_t color) {
    for (int i = 0; i < 1000; ++i) {
        CHRRAM[i] = chr;
        COLRAM[i] = color;
    }
    *BORDER_CHAR_ADDR = chr;
    *BORDER_COLOR_ADDR = color;
}

void main() {
    clear_screen(0x20, 0x01); // Fill with space and color 1
    while (1) {
        // Infinite loop
    }
}
