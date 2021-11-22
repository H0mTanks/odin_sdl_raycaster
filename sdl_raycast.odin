package raycast

import "core:fmt"
import "core:math"
import SDL "vendor:sdl2"
import "Globals"
import "Map"
import "Draw"
import "Entities"

delta_time : f64 = 0.0
old_frame_time : f64 = 0.0

main :: proc() {
    if err := SDL.Init({.VIDEO}); err != 0 {
        fmt.eprintln(err)
        return
    }
    defer SDL.Quit()

    Globals.app.window = SDL.CreateWindow("SDL_Raycaster",
                        SDL.WINDOWPOS_UNDEFINED,
                        SDL.WINDOWPOS_UNDEFINED,
                        Globals.WINDOW_WIDTH, Globals.WINDOW_HEIGHT,
                        {.SHOWN})

    if Globals.app.window == nil {
        fmt.eprintln(SDL.GetError())
        return
    }
    defer SDL.DestroyWindow(Globals.app.window)

    Globals.app.renderer = SDL.CreateRenderer(Globals.app.window, -1, {.SOFTWARE})
    if Globals.app.renderer == nil {
        fmt.eprintln(SDL.GetError())
        return
    }
    defer SDL.DestroyRenderer(Globals.app.renderer)

    
   
    Globals.app.display_buffer = make([]u32, Globals.WINDOW_WIDTH * Globals.WINDOW_HEIGHT)
    if Globals.app.display_buffer == nil {
       fmt.eprintln("Could not allocate buffer");
    }
    defer delete(Globals.app.display_buffer)

    Globals.app.display_buffer_texture = SDL.CreateTexture(Globals.app.renderer,
                                                          cast(u32)(SDL.PixelFormatEnum.RGBA32),
                                                         .STREAMING, Globals.WINDOW_WIDTH, Globals.WINDOW_HEIGHT)

    Globals.is_running = true

    //* Setup the minimap
    Map.allocate_grid(Globals.MAP_NUM_ROWS, Globals.MAP_NUM_COLS)

    //* Initialize the player
    Entities.player.x = cast(f32)(Globals.WINDOW_WIDTH) / 2
    Entities.player.y = cast(f32)(Globals.WINDOW_HEIGHT) / 2
    Entities.player.radius = 5
    Entities.player.turn_direction = 0 
    Entities.player.walk_direction = 0
    Entities.player.rotation_angle = math.PI / 2
    Entities.player.move_speed = 100.0
    Entities.player.rotation_speed = 60.0 * (math.PI / 180)
    Entities.player.color = 0xFFA454D6

    //* setup the rays
    Entities.allocate_rays()

    for Globals.is_running {
        process_input()
        update()
        render()
    }
}

process_input :: proc() {
    event : SDL.Event
    SDL.PollEvent(&event)

    
    #partial switch event.type {
        case .QUIT: {
            Globals.is_running = false
        }
        case .KEYDOWN: {
            if event.key.keysym.sym == .ESCAPE {
                Globals.is_running = false
            }
            if event.key.keysym.sym == .UP {
                Entities.player.walk_direction = +1
            }
            if event.key.keysym.sym == .DOWN {
                Entities.player.walk_direction = -1
            }
            if event.key.keysym.sym == .LEFT {
                Entities.player.turn_direction = -1
            }
            if event.key.keysym.sym == .RIGHT {
                Entities.player.turn_direction = +1
            }
        }
        case .KEYUP: {
            if event.key.keysym.sym == .UP {
                Entities.player.walk_direction = 0
            }
            if event.key.keysym.sym == .DOWN {
                Entities.player.walk_direction = 0
            }
            if event.key.keysym.sym == .LEFT {
                Entities.player.turn_direction = 0
            }
            if event.key.keysym.sym == .RIGHT {
                Entities.player.turn_direction = 0
            } 
        }
        //TODO: other keyboard input events here
    }
}


update :: proc() {
    delta_time = (cast(f64)SDL.GetTicks() - old_frame_time) / 1000.0
    old_frame_time = cast(f64)SDL.GetTicks()

    Entities.update_player(delta_time)
    Entities.cast_all_rays()
}

render :: proc() {
    //* Update DisplayBuffer here
    Map.render_grid()
    Map.render_grid_stroke()
    Entities.render_player()
    Entities.render_all_rays()
    //Draw.line(100, 100, 400, 400, 0xFFFFFFFF)
    //grid();
    //Draw.rectangle(32, 32, 32, 32, 0xFFFFFFFF)

    SDL.UpdateTexture(Globals.app.display_buffer_texture, nil,
                    raw_data(Globals.app.display_buffer),
                    Globals.WINDOW_WIDTH * size_of(u32))

    SDL.RenderCopy(Globals.app.renderer, Globals.app.display_buffer_texture,
                    nil, nil)

    clear_display_buffer()

    SDL.RenderPresent(Globals.app.renderer)
}

clear_display_buffer :: proc() {
    //? check if there's a faster way, perhaps with memset
    for _, i in Globals.app.display_buffer {
        Globals.app.display_buffer[i] = 0
    }
}

