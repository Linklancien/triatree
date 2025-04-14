module main

import math.vec { vec2 }
import gg

const bg_color = gg.Color{0, 0, 0, 255}

struct App {
mut:
	ctx &gg.Context = unsafe { nil }

	tria_ensemble Triatree_Ensemble
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

	app.tria_ensemble.liste_tree << Triatree{
		compo:     Elements.wood
		id:        app.tria_ensemble.liste_tree.len
		dimension: 6
		coo:       []
	}
	app.tria_ensemble.liste_tree[0].divide(mut app.tria_ensemble)

	app.ctx.run()
}

fn on_init(mut app App) {}

fn on_frame(mut app App) {
	app.ctx.begin()
	position := vec2[f32](f32(400), f32(400))
	app.tria_ensemble.liste_tree[0].draw(position, 0, app.tria_ensemble, app.ctx)
	app.ctx.draw_circle_filled(f32(400), f32(400), f32(2), bg_color)
	app.ctx.end()
}

fn on_event(e &gg.Event, mut app App) {}
