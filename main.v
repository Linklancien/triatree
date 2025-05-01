module main

import math.vec { Vec2, vec2 }
import gg

const bg_color = gg.Color{0, 0, 0, 255}
const mouv = 20
const zoom_const = 0.1

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	carte Hexa_world

	//
	draw_nb     int = 1
	rota_cache  [6]f32
	coord_cache map[u64]Vec2[f32]
	view_pos    Vec2[f32]
	zomm_factor f32 = 4
}

const dim_base = 8

fn main() {
	mut app := &App{}
	app.ctx = gg.new_context(
		fullscreen: true

		// width:         100 * 8
		// height:        100 * 8
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
		world: [6]Triatree_Ensemble{init: Triatree_Ensemble{
			liste_tree: init_ensemble_divide(dim_base, 7, Elements.water)
		}}
	}
	/*
	ids := [app.carte.world[0].liste_tree.len - 1, 56, 12, 42, app.carte.world[0].liste_tree.len - 10]
	mut elem := Elements.wood
	for current in 0 .. 6 {
		for id in ids {
			app.carte.world[current].liste_tree[id] = Triatree{
				const_velocity: app.carte.world[current].liste_tree[id].const_velocity
				velocity:       0
				compo:          elem
				id:             id
				dimension:      app.carte.world[current].liste_tree[id].dimension
				coo:            app.carte.world[current].liste_tree[id].coo
			}
			if elem == Elements.wood {
				elem = Elements.stone
			} else {
				elem = Elements.wood
			}
		}
	}
	*/

	app.carte.gen_terrain(dim_base)

	app.ctx.run()
}

fn on_init(mut app App) {
	size := app.ctx.window_size()
	app.ctx.width = size.width
	app.ctx.height = size.height
	app.view_pos = vec2[f32](f32(app.ctx.width / 2), f32(-app.ctx.height / 2))
}

fn on_frame(mut app App) {
	// clear the background (using .passthru later)
	app.ctx.begin()
	app.ctx.end()
	app.ctx.show_fps()

	app.ctx.begin()
	app.draw_nb = 1
	//	app.carte.gravity_update()

	app.carte.draw(app.view_pos, 0, app.zomm_factor, 0, mut app)
	app.ctx.show_fps()
	app.ctx.end(how: .passthru)
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.key_down {
			match e.key_code {
				.up {
					app.view_pos += vec2[f32](f32(0), -f32(mouv))
				}
				.down {
					app.view_pos += vec2[f32](f32(0), f32(mouv))
				}
				.left {
					app.view_pos += vec2[f32](f32(mouv), f32(0))
				}
				.right {
					app.view_pos += vec2[f32](f32(-mouv), f32(0))
				}
				.page_up {
					app.zomm_factor += zoom_const
				}
				.page_down {
					if app.zomm_factor > 1 {
						app.zomm_factor -= zoom_const
					}
				}
				.escape {
					app.ctx.quit()
				}
				else {}
			}
		}
		.mouse_scroll {
			if e.scroll_y > 0 {
				app.zomm_factor += zoom_const
			} else if e.scroll_y < 0 {
				if app.zomm_factor > 1 {
					app.zomm_factor -= zoom_const
				}
			}
		}
		else {}
	}
}
