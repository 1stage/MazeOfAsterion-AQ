#!/usr/bin/env python3
"""
Update all remaining graphics primitive call sites in asterion_func_low.asm
"""

import re

def update_graphics_primitives():
    filename = "src/asterion_func_low.asm"
    
    # Read the file
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Define replacements
    replacements = [
        ('SUB_ram_c869', 'DRAW_DOOR_BOTTOM_SETUP'),
        ('SUB_ram_c86c', 'DRAW_SINGLE_PIXEL_DOWN'),  
        ('SUB_ram_c871', 'DRAW_VERTICAL_LINE_3_DOWN'),
        ('SUB_ram_c87e', 'DRAW_VERTICAL_LINE_3_UP'),
        ('SUB_ram_c886', 'DRAW_CROSS_PATTERN_RIGHT'),
        ('SUB_ram_c893', 'DRAW_CROSS_PATTERN_LEFT'),
        ('SUB_ram_c8a0', 'DRAW_HORIZONTAL_LINE_3_RIGHT'),
        ('SUB_ram_c8ad', 'DRAW_HORIZONTAL_LINE_3_LEFT'),
        ('LAB_ram_c880', 'CONTINUE_VERTICAL_LINE_UP')
    ]
    
    # Apply replacements
    for old_name, new_name in replacements:
        content = content.replace(old_name, new_name)
    
    # Write back to file
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("Updated graphics primitive names in asterion_func_low.asm")

if __name__ == "__main__":
    update_graphics_primitives()