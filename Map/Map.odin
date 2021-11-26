package Map

import "../Draw"
import "../Globals"
import "core:fmt"

Map :: struct {
    grid_rows : i32,
    grid_cols : i32,
    grid : [dynamic]u32,
}

minimap : Map

allocate_grid :: proc(x : i32, y: i32) {
    minimap.grid_rows = x
    minimap.grid_cols = y
    append(&minimap.grid, 
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1,
            1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1,
            1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1,
            1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)

    for y : i32 = 0; y < minimap.grid_rows; y += 1 {
        for x : i32 = 0; x < minimap.grid_cols; x += 1 {
            fmt.printf("%d ", minimap.grid[minimap.grid_cols * y + x])
        }
        fmt.println()
    }
}

is_a_wall :: proc(tileX : f32, tileY : f32) -> bool {
    x : i32 = cast(i32)(tileX / cast(f32)Globals.TILE_SIZE)
    y : i32 = cast(i32)(tileY / cast(f32)Globals.TILE_SIZE)

    if y > Globals.MAP_NUM_ROWS || x > Globals.MAP_NUM_COLS {
        return true
    }

    return minimap.grid[minimap.grid_cols * y + x] != 0
}

render_grid_stroke :: proc() {
    for y : i32 = 0; y < minimap.grid_rows; y += 1 {
        for x : i32 = 0; x < minimap.grid_cols; x += 1 {
            //*get absolute position of tile inside display_buffer
            tileX : i32 = x * Globals.TILE_SIZE
            tileY : i32 = y * Globals.TILE_SIZE

            tile_color : u32 = 0xFF999999

            Draw.rectangle(cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(tileX)), 
                                  cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(tileY)), 
                                  cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(Globals.TILE_SIZE)), 
                                  cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(Globals.TILE_SIZE)), tile_color)
        }
    }
}

render_grid :: proc() {
    for y : i32 = 0; y < minimap.grid_rows; y += 1 {
        for x : i32 = 0; x < minimap.grid_cols; x += 1 {
            //*get absolute position of tile inside display_buffer
            tileX : i32 = x * Globals.TILE_SIZE
            tileY : i32 = y * Globals.TILE_SIZE

            tile_color : u32 = ---
            if minimap.grid[minimap.grid_cols * y + x] == 0 {
                //* empty cell
                tile_color = 0xFFBBBBBB
            }
            else {
                //* filled cell
                tile_color = 0xFF202020
            }

            Draw.filled_rectangle(cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(tileX)), 
                                  cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(tileY)), 
                                  cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(Globals.TILE_SIZE)), 
                                  cast(i32)(Globals.MINIMAP_SCALE_FACTOR * cast(f32)(Globals.TILE_SIZE)), tile_color)
        }
    }
}