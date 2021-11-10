package Globals

import SDL "vendor:sdl2"

is_running : bool = false

TILE_SIZE : i32 : 32
MAP_NUM_ROWS : i32 : 11
MAP_NUM_COLS : i32 : 15

WINDOW_WIDTH : i32 = MAP_NUM_COLS * TILE_SIZE
WINDOW_HEIGHT : i32 = MAP_NUM_ROWS * TILE_SIZE

App :: struct {
    window : ^SDL.Window,
    renderer : ^SDL.Renderer,
    display_buffer : []u32,
    display_buffer_texture : ^SDL.Texture,
}

app : App