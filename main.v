module main

import math.vec { Vec2, vec2 }
import math
import gg

const bg_color = gg.Color{0, 0, 0, 255}
const mouv = 10
const zoom_const = 0.1

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	carte Hexa_world

	//
	view_pos    Vec2[f32]
	zomm_factor f32 = 1
}

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		fullscreen:    false
		width:         100 * 8
		height:        100 * 8
		create_window: true
		window_title:  '- Triatree -'
		user_data:     app
		bg_color:      bg_color
		init_fn:       on_init
		frame_fn:      on_frame
		event_fn:      on_event
		sample_count:  4
	)

	app.carte = Hexa_world{
		world: []Triatree_Ensemble{len: 6, init: Triatree_Ensemble{
			liste_tree: []Triatree{len: 1, init: Triatree{
				const_velocity: f32(60 * math.pow(2, 8))
				compo:          Elements.water
				id:             index
				dimension:      8
				coo:            []
			}}
		}}
	}
	for _ in 0 .. 3 {
		app.carte.divide_rec()
	}

	ids := [app.carte.world[0].liste_tree.len - 1, 56]
	mut elem := Elements.wood
	for id in ids{
		app.carte.world[0].liste_tree[id] = Triatree{
			const_velocity: app.carte.world[0].liste_tree[id].const_velocity
			velocity:       0
			compo:          elem
			id:             id
			dimension:      app.carte.world[0].liste_tree[id].dimension
			coo:            app.carte.world[0].liste_tree[id].coo
		}
		if elem == Elements.wood{
			elem = Elements.stone
		}
		else{
			elem = Elements.wood
		}
	}

	app.ctx.run()
}

fn on_init(mut app App) {}

fn on_frame(mut app App) {
	// clear
	app.ctx.begin()
	app.ctx.end()

	app.carte.gravity_update()

	screen_center := vec2[f32](f32(app.ctx.width / 2), f32(-app.ctx.height / 2)) + app.view_pos
	app.carte.draw(screen_center, 0, app.zomm_factor, 1, app.ctx)
}

fn on_event(e &gg.Event, mut app App) {
	match e.key_code {
		.up {
			app.view_pos += vec2[f32](f32(0), f32(mouv))
		}
		.down {
			app.view_pos += vec2[f32](f32(0), f32(-mouv))
		}
		.left {
			app.view_pos += vec2[f32](f32(-mouv), f32(0))
		}
		.right {
			app.view_pos += vec2[f32](f32(mouv), f32(0))
		}
		.page_up {
			app.zomm_factor += zoom_const
		}
		.page_down {
			if app.zomm_factor != 1 {
				app.zomm_factor -= zoom_const
			}
		}
		else {}
	}
}
