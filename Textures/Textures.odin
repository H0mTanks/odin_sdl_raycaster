package Textures

import "../Globals"

wall_texture : []u32

init_wall_texture :: proc() {
    wall_texture = make([]u32, Globals.TEXTURE_WIDTH * Globals.TEXTURE_HEIGHT)
    for x : i32 = 0; x < Globals.TEXTURE_WIDTH; x += 1 {
        for y : i32 = 0; y < Globals.TEXTURE_HEIGHT; y += 1 {
           //color : u32 = 0xFF0000FF
           //if (x % 8 != 0 )
           wall_texture[(Globals.TEXTURE_WIDTH * y) + x] = ((x % 8 == 0) || (y % 8 == 0)) ? 0xFF000000 : 0xFFFF0000;
        }
    }
}