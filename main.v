module main

import math.vec { vec2 }
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

	// app.tria_ensemble.liste_tree << Triatree{
	// 	compo:     Elements.wood
	// 	id:        app.tria_ensemble.liste_tree.len
	// 	dimension: 8
	// 	coo:       []
	// }
	// app.tria_ensemble.liste_tree[0].divide(mut app.tria_ensemble)
	// app.tria_ensemble.liste_tree[3].divide(mut app.tria_ensemble)
	// app.tria_ensemble.liste_tree[2].divide(mut app.tria_ensemble)
	app.carte = Hexa_world{
		world: []Triatree_Ensemble{len: 6, init: Triatree_Ensemble{
			liste_tree: []Triatree{len: 1, init: Triatree{
				compo:     Elements.wood
				id:        index
				dimension: 8
				coo:       []
			}}
		}}
	}
	app.carte.divide()
	app.carte.world[2].divide()
	app.carte.world[0].divide()
	app.carte.world[0].liste_tree[2].divide(mut app.carte.world[0])

	app.ctx.run()
}

fn on_init(mut app App) {}

fn on_frame(mut app App) {
	app.ctx.begin()
	screen_center := vec2[f32](f32(app.ctx.width / 2), f32(-app.ctx.height / 2))
	app.carte.draw(screen_center, 0, 1, 1, app.ctx)
	app.ctx.draw_circle_filled(f32(400), f32(400), f32(2), bg_color)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {}
