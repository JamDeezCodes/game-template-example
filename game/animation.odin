package game

import rl "vendor:raylib"

Animation :: struct {
	atlas_anim: Animation_Name,
	current_frame: Texture_Name,
	timer: f32,
}

animation_create :: proc(anim: Animation_Name) -> Animation {
	a := atlas_animations[anim]

	return {
		current_frame = a.first_frame,
		atlas_anim = anim,
		timer = atlas_textures[a.first_frame].duration,
	}
}

animation_update :: proc(a: ^Animation, dt: f32) -> bool {
	a.timer -= dt
	looped := false

	if a.timer <= 0 {
		a.current_frame = Texture_Name(int(a.current_frame) + 1)
		anim := atlas_animations[a.atlas_anim]

		if a.current_frame > anim.last_frame {
			a.current_frame = anim.first_frame
			looped = true
		}

		a.timer = atlas_textures[a.current_frame].duration
	}

	return looped
}

animation_length :: proc(anim: Animation_Name) -> f32 {
	l: f32
	aa := atlas_animations[anim]

	for i in aa.first_frame..=aa.last_frame {
		t := atlas_textures[i]
		l += t.duration
	}

	return l
}

animation_draw :: proc(anim: Animation, pos: Vec2, flip_x := false) {
	if anim.current_frame == .None {
		return
	}

	texture := atlas_textures[anim.current_frame]
	
	// Note: The texture.offset may contain a non-zero offset. This offset occurs
	// when textures have some empty pixels in the upper regions. Instead of the
	// packer writing in those empty pixels (wasting space), it record how much
	// you need to offset your texture to compensate for the missing empty pixels.
	offset_pos := pos + {f32(texture.offset.x), f32(texture.offset.y)}
	atlas_rect := texture.rect

	if flip_x {
		atlas_rect.width = -atlas_rect.width
	}

	rl.DrawTextureRec(atlas, atlas_rect, offset_pos, rl.WHITE)
}