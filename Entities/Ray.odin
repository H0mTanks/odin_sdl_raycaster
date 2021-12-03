package Entities

import "../Globals"
import "../Draw"
import "../Map"
import "../Textures"
import "core:math"
import "core:fmt"

//TODO: Test with an SOA struct
//TODO: See which fields of ray struct can just be local variables
Ray :: struct {
    ray_angle : f32,
    wall_hit_x : f32,
    wall_hit_y : f32,
    distance : f32,
    was_hit_vertical : bool,
    
    is_ray_facing_down : bool,
    is_ray_facing_up : bool,

    is_ray_facing_right : bool,
    is_ray_facing_left : bool,
}

rays : []Ray

allocate_rays :: proc() {
    rays = make([]Ray, Globals.NUM_RAYS)
}

render_ray :: proc(ray : ^Ray) {
    Draw.line(cast(i32)(Globals.MINIMAP_SCALE_FACTOR * player.x), 
              cast(i32)(Globals.MINIMAP_SCALE_FACTOR * player.y), 
              cast(i32)(Globals.MINIMAP_SCALE_FACTOR * ray.wall_hit_x),
              cast(i32)(Globals.MINIMAP_SCALE_FACTOR * ray.wall_hit_y),
              0xFFFCB900)
}

//? SIMD this
render_all_rays :: proc() {
    for _, i in rays {
        render_ray(&rays[i])
    }
}

render_projection_3D :: proc() {
    for ray, i in rays {
        perp_distance : f32 = ray.distance * math.cos(ray.ray_angle - player.rotation_angle);
        distance_proj_plane : f32 = (cast(f32)Globals.WINDOW_WIDTH / 2) / math.tan(Globals.FOV_ANGLE / 2);
        projected_wall_height : f32 = (cast(f32)Globals.TILE_SIZE / perp_distance) * distance_proj_plane

        wall_strip_height : i32 = cast(i32)projected_wall_height

        wall_top_pixel : i32 = (Globals.WINDOW_HEIGHT / 2) - (wall_strip_height / 2)
        wall_top_pixel = wall_top_pixel < 0 ? 0 : wall_top_pixel

        wall_bottom_pixel : i32 = (Globals.WINDOW_HEIGHT / 2) + (wall_strip_height / 2)
        wall_bottom_pixel = wall_bottom_pixel > Globals.WINDOW_HEIGHT ? Globals.WINDOW_HEIGHT : wall_bottom_pixel

        color_factor : f32 = math.remainder(ray.distance, cast(f32)Globals.TILE_SIZE * 16) / cast(f32)(Globals.TILE_SIZE * 16)
        color_factor = color_factor < 0 ? 0.5 : color_factor
        color_factor *= 1.5
        //fmt.println(color_factor)

        //*render the ceiling
        for y : i32 = 0; y < wall_top_pixel; y += 1 {
            Draw.pixel(cast(i32)i, y, /*Draw.factor_color(*/0xFF333333/*, color_factor)*/)
        }

        texture_offset_x : i32 = ---
        if (ray.was_hit_vertical) {
            texture_offset_x = cast(i32)ray.wall_hit_y % Globals.TEXTURE_HEIGHT
        }
        else {
            texture_offset_x = cast(i32)ray.wall_hit_x % Globals.TEXTURE_WIDTH
        }

        //*render the wall in the middle
        for y : i32 = wall_top_pixel; y < wall_bottom_pixel; y += 1 {
            distance_from_top : i32 = y + (wall_strip_height / 2) - (Globals.WINDOW_HEIGHT / 2)
            texture_offset_y : i32 = cast(i32)(cast(f32)distance_from_top * (cast(f32)Globals.TEXTURE_HEIGHT / cast(f32)wall_strip_height))

            texel_color : u32 = Textures.wall_texture[(Globals.TEXTURE_WIDTH * texture_offset_y) + texture_offset_x]
            Draw.pixel(cast(i32)i, y, texel_color)
            //Draw.pixel(cast(i32)i, y, (ray.was_hit_vertical ? Draw.factor_color(0xFFEEEEEE, color_factor) : Draw.factor_color(0xFFCCCCCC, color_factor)))
            //Draw.pixel(cast(i32)i, y, (ray.was_hit_vertical ? 0x55EEEEEE : 0xFFCCCCCC))
        }   

        //* render the floor
        for y : i32 = wall_bottom_pixel; y < Globals.WINDOW_HEIGHT; y += 1 {
            Draw.pixel(cast(i32)i, y, /*Draw.factor_color(*/0xFF777777, /*Draw.factor_color(*/)
        }
    }
}

distance_between_points :: proc(x1, y1, x2, y2 : f32) -> f32 {
    return math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
}

//TODO: Check if column ID is needed
cast_ray :: proc(ray : ^Ray, column_id : i32) {
    x_intercept, y_intercept : f32
    x_step, y_step : f32

    //*HORIZONTAL RAY GRID INTERSECTION
    found_horz_wall_hit := false
    horz_wall_hit_x : f32
    horz_wall_hit_y : f32

    //*y coord of the closest horizontal grid intersection
    y_intercept = math.floor(player.y / cast(f32)Globals.TILE_SIZE) * cast(f32)Globals.TILE_SIZE
    y_intercept += ray.is_ray_facing_down ? cast(f32)Globals.TILE_SIZE : 0

    //*x coord of the closest horizontal grid intersection
    x_intercept = player.x + (y_intercept - player.y) / math.tan(ray.ray_angle)

    //*calculate increments x_step and y_step
    y_step = cast(f32)Globals.TILE_SIZE
    y_step *= ray.is_ray_facing_up ? -1 : 1

    x_step = cast(f32)Globals.TILE_SIZE / math.tan(ray.ray_angle)
    x_step *= (ray.is_ray_facing_left && x_step > 0) ? -1 : 1
    x_step *= (ray.is_ray_facing_right && x_step < 0) ? -1 : 1

    next_horz_touch_x : f32 = x_intercept
    next_horz_touch_y : f32 = y_intercept

    //*increment xstep and ystep until we find a wall
    for (next_horz_touch_x >= 0 && next_horz_touch_x <= cast(f32)Globals.WINDOW_WIDTH && next_horz_touch_y >= 0 && next_horz_touch_y <= cast(f32)Globals.WINDOW_HEIGHT) {
        if Map.is_a_wall(next_horz_touch_x, next_horz_touch_y + (ray.is_ray_facing_up ? -1 : 0)) {
            found_horz_wall_hit = true
            horz_wall_hit_x = next_horz_touch_x
            horz_wall_hit_y = next_horz_touch_y
            break
        }
        else {
            next_horz_touch_x += x_step
            next_horz_touch_y += y_step
        }
    }

    //* VERTICAL RAY GRID INTERSECTION
    found_vert_wall_hit := false
    vert_wall_hit_x : f32
    vert_wall_hit_y : f32

    x_intercept = math.floor(player.x / cast(f32)Globals.TILE_SIZE) * cast(f32)Globals.TILE_SIZE
    x_intercept += ray.is_ray_facing_right ? cast(f32)Globals.TILE_SIZE : 0

    y_intercept = player.y + (x_intercept - player.x) * math.tan(ray.ray_angle)

    x_step = cast(f32)Globals.TILE_SIZE
    x_step *= ray.is_ray_facing_left ? -1 : 1

    y_step = cast(f32)Globals.TILE_SIZE * math.tan(ray.ray_angle)
    y_step *= (ray.is_ray_facing_up && y_step > 0) ? -1 : 1
    y_step *= (ray.is_ray_facing_down && y_step < 0) ? -1 : 1

    next_vert_touch_x : f32 = x_intercept
    next_vert_touch_y : f32 = y_intercept

    for (next_vert_touch_x >= 0 && next_vert_touch_x <= cast(f32)Globals.WINDOW_WIDTH && next_vert_touch_y >= 0 && next_vert_touch_y <= cast(f32)Globals.WINDOW_HEIGHT) {
        if Map.is_a_wall(next_vert_touch_x + ((ray.is_ray_facing_left) ? -1 : 0), next_vert_touch_y) {
            found_vert_wall_hit = true
            vert_wall_hit_x = next_vert_touch_x
            vert_wall_hit_y = next_vert_touch_y
            break
        }
        else {
            next_vert_touch_x += x_step
            next_vert_touch_y += y_step
        }
    }

    //*calculate both horizontal and vertical distances and choose the smallest value
    horz_hit_distance : f32 = found_horz_wall_hit ? distance_between_points(player.x, player.y, horz_wall_hit_x, horz_wall_hit_y) : math.F32_MAX
    vert_hit_distance : f32 = found_vert_wall_hit ? distance_between_points(player.x, player.y, vert_wall_hit_x, vert_wall_hit_y) : math.F32_MAX

    //TODO: put in an if statement
    //*store smallest distance
    ray.wall_hit_x = (horz_hit_distance < vert_hit_distance) ? horz_wall_hit_x : vert_wall_hit_x
    ray.wall_hit_y = (horz_hit_distance < vert_hit_distance) ? horz_wall_hit_y : vert_wall_hit_y
    ray.distance = (horz_hit_distance < vert_hit_distance) ? horz_hit_distance : vert_hit_distance
    ray.was_hit_vertical = vert_hit_distance < horz_hit_distance

}

cast_all_rays :: proc() {
    //*start first ray subtracting half of FOV
    ray_angle : f32 = player.rotation_angle - (Globals.FOV_ANGLE / 2)

    for column_id : i32 = 0; column_id < Globals.NUM_RAYS; column_id += 1 {
        ray : Ray
        //*setup the ray
        ray.ray_angle = normalise_angle(ray_angle)
        ray.is_ray_facing_down = ray.ray_angle > 0 && ray.ray_angle < math.PI
        ray.is_ray_facing_up = !ray.is_ray_facing_down
        ray.is_ray_facing_right = ray.ray_angle < 0.5 * math.PI || ray.ray_angle > 1.5 * math.PI
        ray.is_ray_facing_left = !ray.is_ray_facing_right

        cast_ray(&ray, column_id)

        rays[column_id] = ray
        ray_angle += Globals.FOV_ANGLE / cast(f32)Globals.NUM_RAYS
    }
}

normalise_angle :: proc(ray_angle : f32) -> f32 {
    //!change remainder to mod?
    angle : f32 = math.remainder(ray_angle, (2 * math.PI))
    if angle < 0 {
        angle += (2 * math.PI)
    }
    return angle
}