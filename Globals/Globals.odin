package Globals

import SDL "vendor:sdl2"
import "core:math"

is_running : bool = false

TILE_SIZE : i32 : 64
MAP_NUM_ROWS : i32 : 11
MAP_NUM_COLS : i32 : 15
MINIMAP_SCALE_FACTOR : f32 : 0.25

WINDOW_WIDTH : i32 = MAP_NUM_COLS * TILE_SIZE
WINDOW_HEIGHT : i32 = MAP_NUM_ROWS * TILE_SIZE

FOV_ANGLE : f32 : 60 * (math.PI / 180)

WALL_STRIP_WIDTH : i32 : 1
NUM_RAYS : i32 = WINDOW_WIDTH / WALL_STRIP_WIDTH

TEXTURE_WIDTH : i32 : TILE_SIZE //?64
TEXTURE_HEIGHT : i32 : TILE_SIZE //?64
NUM_TEXTURES : i32 : 8

App :: struct {
    window : ^SDL.Window,
    renderer : ^SDL.Renderer,
    display_buffer : []u32,
    display_buffer_texture : ^SDL.Texture,
}

app : App