module main

import math.vec { vec2 }
import math
import gg

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	carte Hexa_world
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

	app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 1] = Triatree{
		const_velocity: app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 1].const_velocity
		velocity:       0
		compo:          Elements.stone
		id:             app.carte.world[0].liste_tree.len - 1
		dimension:      app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 1].dimension
		coo:            app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 1].coo
	}

	app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 20] = Triatree{
		const_velocity: app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 20].const_velocity
		velocity:       0
		compo:          Elements.stone
		id:             app.carte.world[0].liste_tree.len - 20
		dimension:      app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 20].dimension
		coo:            app.carte.world[0].liste_tree[app.carte.world[0].liste_tree.len - 20].coo
	}

	app.ctx.run()
}

fn on_init(mut app App) {}

fn on_frame(mut app App) {
	// clear
	app.ctx.begin()
	app.ctx.end()

	app.carte.gravity_update()

	screen_center := vec2[f32](f32(app.ctx.width / 2), f32(-app.ctx.height / 2))
	app.carte.draw(screen_center, 0, 1, 1, app.ctx)
	app.ctx.draw_circle_filled(f32(400), f32(400), f32(2), bg_color)
}

fn on_event(e &gg.Event, mut app App) {}
