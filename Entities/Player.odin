package Entities

import "../Draw"
import "../Globals"
import "../Map"
import "core:math"

Player :: struct {
    x : f32,
    y : f32,
    //width : f32
    //height : f32
    radius : i32,
    turn_direction : i32, //* -1 if left, +1 if right */
    walk_direction : i32, //* -1 if back, +1 if front */
    rotation_angle : f32,
    move_speed : f32,
    rotation_speed : f32,
    color : u32,
}

player : Player

update_player :: proc(delta_time : f64) {
    player.rotation_angle += cast(f32)player.turn_direction * player.rotation_speed * cast(f32)delta_time
    move_step : f32 = cast(f32)player.walk_direction * player.move_speed * cast(f32)delta_time

    new_x : f32 = player.x + math.cos_f32(player.rotation_angle) * move_step
    new_y : f32 = player.y + math.sin_f32(player.rotation_angle) * move_step

    if !Map.is_a_wall(new_x, new_y) {
        player.x = new_x
        player.y = new_y
    }
}

render_player :: proc() {
    Draw.filled_circle(cast(i32)player.x, cast(i32)player.y, player.radius, player.color)
    Draw.line(cast(i32)player.x, cast(i32)player.y, 
            cast(i32)(player.x + math.cos_f32(player.rotation_angle) * 30), 
            cast(i32)(player.y + math.sin_f32(player.rotation_angle) * 30),
            player.color)
}