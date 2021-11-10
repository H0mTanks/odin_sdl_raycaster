package Draw

import "../Globals"

pixel :: proc(x : i32, y : i32, color : u32) {
    if x < Globals.WINDOW_WIDTH && y < Globals.WINDOW_HEIGHT && x >= 0 && y >= 0 {
		Globals.app.display_buffer[Globals.WINDOW_WIDTH * y + x] = color;
	}
}

line :: proc(x0 : i32, y0 : i32, x1 : i32, y1 : i32, color : u32) {
	x0 : i32 = x0
	y0 : i32 = y0

	dx : i32 = abs(x1 - x0)
	sx : i32 = x0 < x1 ? 1 : -1

	dy : i32 = (-abs(y1 - y0))
	sy : i32 = y0 < y1 ? 1 : -1

	error : i32 = dx + dy
	for {
		pixel(x0, y0, color)
		if x0 == x1 && y0 == y1 do break

		error2 : i32 = error * 2
		if error2 >= dy {
			error += dy
			x0 += sx
		}

		if (error2 <= dx) {
			error += dx
			y0 += sy
		}
	}

}

filled_circle :: proc(xo : i32, yo: i32, radius : i32, color : u32) {
	for y: i32 = -radius; y <= radius; y += 1 {
		for x : i32 = -radius; x <= radius; x += 1 {
			if x*x + y*y <= radius * radius {
				pixel(xo+x, yo+y, color);
			}
		}
	}
}

rectangle :: proc(x : i32, y : i32, width : i32, height : i32, color : u32) {
	//TODO: use a line drawing function instead
	for j : i32 = y; j <= y + height; j += 1 {
		for i : i32 = x; i < x + width; i += 1 {
			if j == y || j == y + height {
				pixel(i, j, color)
			}
			else {
				pixel(i, j, color)
				i += width - 1
				pixel(i, j, color)
			}
		}
	}
}

filled_rectangle :: proc(x : i32, y : i32, width : i32, height : i32, color : u32) {
	for j : i32 = y; j < y + height; j += 1 {
		for i : i32 = x; i < x + width; i += 1 {
			pixel(i, j, color)
		}
	}
}