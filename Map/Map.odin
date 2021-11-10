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

render_grid_stroke :: proc() {
    for y : i32 = 0; y < minimap.grid_rows; y += 1 {
        for x : i32 = 0; x < minimap.grid_cols; x += 1 {
            //*get absolute position of tile inside display_buffer
            tileX : i32 = x * Globals.TILE_SIZE
            tileY : i32 = y * Globals.TILE_SIZE

            tile_color : u32 = 0xFF999999

            Draw.rectangle(tileX, tileY, Globals.TILE_SIZE, Globals.TILE_SIZE, tile_color)
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

            Draw.filled_rectangle(tileX, tileY, Globals.TILE_SIZE, Globals.TILE_SIZE, tile_color)
        }
    }
}