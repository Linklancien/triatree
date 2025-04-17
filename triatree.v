module main

import math
import math.vec { Vec2, vec2 }
import gg
import rand

const triabase = [0, 1, 2, 3]
const center = vec2[f32](f32(0), f32(0))

enum Elements {
	// element is a key of the elements_caras map
	wood
}

const elements_caras = {
	Elements.wood: Cara{
		color: gg.Color{125, 125, 125, 255}
	}
}

struct Cara {
	// quantitées intensives
	color gg.Color
}

type Self = Elements | Childs

struct Triatree_Ensemble {
mut:
	free_index []int // len%4 == 0 always ?
	liste_tree []Triatree
}

struct Hexa_world {
mut:
	world []Triatree_Ensemble
}

struct Triatree {
mut:
	compo Self

	id        int
	dimension int

	// entre dimensions_max et 0
	coo []int
}

struct Childs {
	mid   int
	up    int
	left  int
	right int
}

// COO TRIA TO CART:
fn coo_tria_to_cart(coo []int, rota f32, dimensions_max int) Vec2[f32] {
	mut position := vec2[f32](0.0, 0.0)
	mut angle := rota
	for id in 0 .. coo.len {
		dim := dimensions_max - id - 1
		dist := f32(math.pow(2, dim) / math.sqrt(3))
		if coo[id] == 0 {
			angle += math.pi
		} else if coo[id] == 1 {
			position += vec2[f32](dist, 0).rotate_around_ccw(center, angle - math.pi / 2)
		} else if coo[id] == 2 {
			position += vec2[f32](dist, 0).rotate_around_ccw(center, angle + math.pi / 6)
		} else if coo[id] == 3 {
			position += vec2[f32](dist, 0).rotate_around_ccw(center, angle + math.pi * 5 / 6)
		}
	}
	return position
}

fn hexa_world_coo_tria_to_cart(coo []int, current int, dimensions_max int) Vec2[f32] {
	rota := f32(current - 1) * math.pi / 3
	dist := f32(math.pow(2, dimensions_max) / math.sqrt(3))
	coo_in_triangle := (coo_tria_to_cart(coo, 0, dimensions_max) + vec2[f32](0, dist)).rotate_around_ccw(center,
		rota)
	return coo_in_triangle
}

// return the coo of the 3 corners of a triangle in order [1, 2, 3]
fn coo_cart_corners(coo []int, rota f32, dimensions_max int) (Vec2[f32], Vec2[f32], Vec2[f32]) {
	center_pos := coo_tria_to_cart(coo, rota, dimensions_max)
	mut angle := rota
	for id in 0 .. coo.len {
		if coo[id] == 0 {
			angle += math.pi
		}
	}
	dist := f32(math.pow(2, dimensions_max - coo.len) / math.sqrt(3))
	pos1 := center_pos + vec2[f32](dist, 0).rotate_around_ccw(center, angle + math.pi * 3 / 2)
	pos2 := center_pos + vec2[f32](dist, 0).rotate_around_ccw(center, angle + math.pi / 6)
	pos3 := center_pos + vec2[f32](dist, 0).rotate_around_ccw(center, angle + math.pi * 5 / 6)
	return pos1, pos2, pos3
}

// COO CART TO TRIA:
fn coo_cart_to_tria(pos Vec2[f32], dimension int) []int {
	// at the start the child 1 of the hugest triangle is pointing downward
	if dimension == 0 {
		return []int{}
	}

	abs_x := math.pow(2, dimension)

	// using math:
	// check if the position is inside the triangle
	ratio_out := pos.y / math.sqrt(3) + abs_x / 3
	if pos.y > abs_x / (2 * math.sqrt(3)) || pos.x > ratio_out || -pos.x > ratio_out {
		// panic('Not in trianlge dim: $dimension, \n pos: $pos \n ${pos.y >= abs_x /(2* math.sqrt(3))} \n ${pos.x > ratio_out} \n ${-pos.x > ratio_out}')
		return []int{}
	}

	// check in which child of the triangle is the position
	mut coo := 0
	ratio_in := pos.y / math.sqrt(3) - abs_x / 6
	if pos.y < -abs_x / (4 * math.sqrt(3)) {
		coo = 1
	} else if -pos.x < ratio_in {
		coo = 2
	} else if pos.x < ratio_in {
		coo = 3
	} else {
		coo = 0
	}

	// compute the position of the child compared to the center of the current triangle
	mut actual_pos := center
	dist := f32(abs_x / (2 * math.sqrt(3)))
	if coo == 1 {
		actual_pos += vec2[f32](dist, 0).rotate_around_ccw(center, -math.pi / 2)
	} else if coo == 2 {
		actual_pos += vec2[f32](dist, 0).rotate_around_ccw(center, math.pi / 6)
	} else if coo == 3 {
		actual_pos += vec2[f32](dist, 0).rotate_around_ccw(center, math.pi * 5 / 6)
	}

	// compute the position relative to the child center
	mut previous_pos := pos - actual_pos

	// rotate the position if the triangle is upside down == the child is 0
	if coo == 0 {
		previous_pos = previous_pos.rotate_around_cw(center, math.pi)
	}

	mut final_coo := [coo]
	final_coo << coo_cart_to_tria(previous_pos, dimension - 1)
	return final_coo
}

fn hexa_world_coo_cart_to_tria(pos Vec2[f32], dimension_precision int) ([]int, int) {
	// to complete
	mut current := -1
	mut angle := pos.angle()
	if angle < 0 {
		angle += 2 * math.pi
	}
	for i in 0 .. 6 {
		if i * math.pi / 3 <= angle && angle <= (i + 1) * math.pi / 3 {
			current = i
			break
		}
	}
	if current == -1 {
		panic('Not found, pos: ${pos}, angle: ${angle}')
	}

	rota := f32(current - 1) * math.pi / 3
	dist := f32(math.pow(2, dimension_precision) / math.sqrt(3))
	position := pos.rotate_around_cw(center, rota) - vec2[f32](0, dist)
	coo := coo_cart_to_tria(position, dimension_precision)

	return coo, current
}

// NEIGHBORS:
fn neighbors(coo []int) [][]int {
	n := coo.len
	mut nei := [][]int{}
	if coo[n - 1] == 0 {
		// 0 is the center of the triangle so its neighbors can only be 1 2 3 of the same triangle
		for i in 1 .. 4 {
			nei << coo[..n - 1]
			nei[nei.len - 1] << [i]
		}
		return nei
	}

	nei << coo[..n - 1]
	nei[0] << [0]
	mut to_ad := remove_from_base(triabase, [0, coo[n - 1]])

	// au sein du même triangle, le triangle {1, 2, 3} sera toujours opposé au triangle [0]x{1, 2, 3}, pour la même valeur
	// 1 out of 3
	mut first_stop := -1
	for tempo_id in 0 .. n {
		id := n - tempo_id - 1
		if coo[id] != coo[n - 1] && coo[id] != first_stop {
			if coo[id] == 0 && to_ad.len == 2 {
				if coo == [0, 0, 1, 2] {
					panic(to_ad)
				}
				nei << coo[..id]
				nei[nei.len - 1] << to_ad[0]
				nei[nei.len - 1] << []int{len: tempo_id, init: to_ad[1]}

				nei << coo[..id]
				nei[nei.len - 1] << to_ad[1]
				nei[nei.len - 1] << []int{len: tempo_id, init: to_ad[0]}
				return nei
			} else {
				// coo[id] appartient a {1, 2, 3}\{coo[n-1]}
				if to_ad.len == 2 {
					possible := remove_from_base(to_ad, [coo[id]])
					if possible.len == 1 {
						nei << coo[..id]
						nei[nei.len - 1] << [0]
						nei[nei.len - 1] << []int{len: tempo_id, init: possible[0]}

						to_ad = remove_from_base(to_ad, possible)
						first_stop = coo[id]
					}
				} else if to_ad.len == 1 {
					nei << coo[..id]
					mut orientation := [0]
					if coo[id] == 0 {
						orientation = remove_from_base(triabase, [0, coo[n - 1], to_ad[0]])
					}
					nei[nei.len - 1] << orientation

					new_base := remove_from_base(triabase, [coo[id], orientation[0]])

					// new_base.len == 2
					for finition in (id + 1) .. n {
						nei[nei.len - 1] << remove_from_base(new_base, [coo[finition]])
					}

					return nei
				}
			}
		}
	}

	return nei
}

fn hexa_world_neighbors(coo []int, current int) ([]int, [][]int) {
	if coo == [] {
		near := hexa_near_triangle(current)
		return [near[0], near[2]], [[]int{}, []int{}]
	}

	mut directs_neighbors := neighbors(coo)

	if directs_neighbors.len == 1 {
		if coo[0] == 1 {
			directs_neighbors << []int{len: coo.len, init: 1}
			directs_neighbors << []int{len: coo.len, init: 1}

			// the order doesn't matter because they are all [1, 1, ..., 1]
			// this is the nearest of the center of the world
			return hexa_near_triangle(current), directs_neighbors
		}
	}
	if directs_neighbors.len <= 2 {
		mut nei := []int{}
		possible := [2, 3]
		mut other := -1
		for id in 0 .. coo.len {
			if coo[id] == 1 {
				nei << [1]
			} else {
				other = coo[id]
				nei << remove_from_base(possible, [coo[id]])
			}
		}
		directs_neighbors << nei
		tria_nei := hexa_near_triangle(current)
		mut near := [tria_nei[1]]
		if other == 2 {
			if other == 2 {
				near << [tria_nei[2]]
			} else if other == 3 {
				near << [tria_nei[1]]
			}
			return near, directs_neighbors
		}
	}

	// else{panic("A 0 without 3 neigbors in it's base ??? coo: ${coo} current: ${current}")}
	// coo is inside a triangle
	return []int{len: 3, init: current}, directs_neighbors
}

// graphics:
fn (tree Triatree) draw(pos_center Vec2[f32], rota f32, zomm_factor f32, parent Triatree_Ensemble, ctx gg.Context) {
	match tree.compo {
		Elements {
			pos := pos_center + (coo_tria_to_cart(tree.coo, rota, tree.dimension +
				tree.coo.len)).mul_scalar(zomm_factor)
			mut angle := -rota - math.pi / 6

			mut is_reverse := false
			for elem in tree.coo {
				if elem == 0 {
					is_reverse = !is_reverse
				}
			}

			if is_reverse {
				angle += math.pi
			}
			size := f32(zomm_factor * math.pow(2, tree.dimension) / math.sqrt(3)) - 1
			ctx.begin()
			ctx.draw_polygon_filled(pos.x, -pos.y, size, 3, f32(math.degrees(angle)),
				elements_caras[tree.compo].color)
			ctx.end(how: .passthru)
		}
		Childs {
			parent.liste_tree[tree.compo.mid].draw(pos_center, rota, zomm_factor, parent,
				ctx)
			parent.liste_tree[tree.compo.up].draw(pos_center, rota, zomm_factor, parent,
				ctx)
			parent.liste_tree[tree.compo.left].draw(pos_center, rota, zomm_factor, parent,
				ctx)
			parent.liste_tree[tree.compo.right].draw(pos_center, rota, zomm_factor, parent,
				ctx)
		}
	}
}

fn (tria_ensemble Triatree_Ensemble) draw(pos_center Vec2[f32], rota f32, zomm_factor f32, ctx gg.Context) {
	if tria_ensemble.liste_tree.len != 0 {
		tria_ensemble.liste_tree[0].draw(pos_center, rota, zomm_factor, tria_ensemble,
			ctx)
	}
}

fn (hexa_world Hexa_world) draw(pos_center Vec2[f32], rota f32, zomm_factor f32, current int, ctx gg.Context) {
	for i in 0 .. 6 {
		if hexa_world.world[i].liste_tree.len != 0 {
			angle := rota + (i - f32(current)) * math.pi / 3

			dim := hexa_world.world[i].liste_tree[0].dimension
			dist := f32(math.pow(2, dim) / math.sqrt(3))
			pos := pos_center + (vec2[f32](0, dist)).rotate_around_ccw(center, angle)

			hexa_world.world[i].draw(pos, angle, zomm_factor, ctx)
		}
	}
}

// find
fn (tree Triatree) go_to(coo []int, parent Triatree_Ensemble) int {
	if coo == tree.coo {
		return tree.id
	}
	match tree.compo {
		Childs {
			if coo[0] == 0 {
				return parent.liste_tree[tree.compo.mid].go_to(coo[1..], parent)
			} else if coo[0] == 1 {
				return parent.liste_tree[tree.compo.up].go_to(coo[1..], parent)
			} else if coo[0] == 2 {
				return parent.liste_tree[tree.compo.left].go_to(coo[1..], parent)
			} else if coo[0] == 3 {
				return parent.liste_tree[tree.compo.right].go_to(coo[1..], parent)
			}
		}
		Elements {
			// closest parent
			return tree.id
		}
	}
	panic('not found')
	return -1
}

// PHYSIC:
// TODO: prendre en compte si les case sont occupé lorsque 2 cases peuvent être les suivantes
// maybe change by adding a new fonction

// take a position, and a corner towards which is applied the gravity and return the next likely position
fn gravity(coo []int, center int) []int {
	n := coo.len

	if coo == [] {
		return []
	}

	is_reverse := check_reverse(coo)

	// next position:

	// check if the current coo is at the gravity center
	mut is_center := true
	for i in 0 .. n {
		id := n - i - 1
		if coo[id] != center {
			is_center = false
			break
		}
	}

	if is_center {
		return coo
	}

	nei := neighbors(coo)
	mut next := coo[..n - 1].clone()
	if is_reverse {
		if coo[n - 1] == 0 {
			next_final_nei := remove_from_base(triabase, [0, center])
			mut final_co := 0
			if rand.bernoulli(0.5) or { false } {
				final_co = next_final_nei[0]
			} else {
				final_co = next_final_nei[1]
			}

			// used to find the neighbor that end with the desired value
			for elem in nei {
				if elem[n - 1] == final_co {
					next = elem.clone()
					break
				}
			}
		} else if coo[n - 1] == center {
			next << 0
		} else {
			final_co := remove_from_base(triabase, [0, center, coo[n - 1]])[0]
			for elem in nei {
				if elem[n - 1] == final_co {
					next = elem.clone()
					break
				}
			}
		}
	} else {
		if coo[n - 1] == 0 {
			next << center
		} else if coo[n - 1] == center {
			next_final_nei := remove_from_base(triabase, [0, center])

			if nei.len == 2 {
				// in this case there is only one of the two neighbors which is closer to the center of gravity
				for elem in nei {
					if elem[n - 1] == next_final_nei[0] || elem[n - 1] == next_final_nei[1] {
						next = elem.clone()
						break
					}
				}
			} else {
				mut final_co := 0
				if rand.bernoulli(0.5) or { false } {
					final_co = next_final_nei[0]
				} else {
					final_co = next_final_nei[1]
				}

				// used to find the neighbor that end with the desired value
				for elem in nei {
					if elem[n - 1] == final_co {
						next = elem.clone()
						break
					}
				}
			}
		} else {
			next << 0
		}
	}

	return next
}

// DIVIDE & MERGE:
// DIVIDE:

// Divide for TRIATREE
fn (mut tree Triatree) divide(mut parent Triatree_Ensemble) {
	if tree.dimension > 0 {
		match tree.compo {
			Elements {
				mut ids := []int{}
				for new in 0 .. 4 {
					mut next_coo := tree.coo.clone()
					next_coo << [new]

					mut id := -1
					if parent.free_index.len != 0 {
						id = parent.free_index.pop()
						parent.liste_tree[id] = Triatree{
							compo:     tree.compo
							id:        id
							dimension: (tree.dimension - 1)
							coo:       next_coo
						}
					} else {
						id = parent.liste_tree.len
						parent.liste_tree << [
							Triatree{
								compo:     tree.compo
								id:        id
								dimension: (tree.dimension - 1)
								coo:       next_coo
							},
						]
					}
					ids << [id]
				}
				parent.liste_tree[tree.id] = Triatree{
					compo:     Childs{
						mid:   ids[0]
						up:    ids[1]
						left:  ids[2]
						right: ids[3]
					}
					id:        tree.id
					dimension: tree.dimension
					coo:       tree.coo.clone()
				}
			}
			else {}
		}
	}
}

// Divide for TRIA_ENSEMBLE:
fn (mut tria_ensemble Triatree_Ensemble) divide(index int) {
	match tria_ensemble.liste_tree[index].compo {
		Elements {
			tria_ensemble.liste_tree[index].divide(mut tria_ensemble)
		}
		else {}
	}
}

fn (mut tria_ensemble Triatree_Ensemble) divide_rec(index int) {
	match tria_ensemble.liste_tree[index].compo {
		Elements {
			tria_ensemble.liste_tree[index].divide(mut tria_ensemble)
		}
		Childs {
			tria_ensemble.divide_rec(tria_ensemble.liste_tree[index].compo.mid)
			tria_ensemble.divide_rec(tria_ensemble.liste_tree[index].compo.up)
			tria_ensemble.divide_rec(tria_ensemble.liste_tree[index].compo.left)
			tria_ensemble.divide_rec(tria_ensemble.liste_tree[index].compo.right)
		}
	}
}

// Divide for HEXA_WORLD:
fn (mut hexa_world Hexa_world) divide(index int) {
	for mut tria_ensemble in hexa_world.world {
		tria_ensemble.divide(index)
	}
}

fn (mut hexa_world Hexa_world) divide_rec() {
	for mut tria_ensemble in hexa_world.world {
		tria_ensemble.divide_rec(0)
	}
}

// MERGE:

// Merge for TRIATREE
fn (tree Triatree) merge(mut parent Triatree_Ensemble) {
	match tree.compo {
		Childs {
			if tree.check_mergeable(parent) {
				parent.free_index << [tree.compo.mid]
				parent.free_index << [tree.compo.up]
				parent.free_index << [tree.compo.left]
				parent.free_index << [tree.compo.right]

				parent.liste_tree[tree.id] = Triatree{
					compo:     parent.liste_tree[tree.compo.mid].compo
					id:        tree.id
					dimension: tree.dimension
					coo:       tree.coo.clone()
				}
			}
		}
		else {}
	}
}

// Merge for TRIATREE_ENSEMBLE
fn (mut tria_ensemble Triatree_Ensemble) merge(index int) {
	tria_ensemble.liste_tree[index].merge(mut tria_ensemble)
}

// Merge for HEXA_WORLD:
fn (mut hexa_world Hexa_world) merge(index int) {
	for mut tria_ensemble in hexa_world.world {
		tria_ensemble.merge(index)
	}
}

// UTILITARY:
// for the id of a triatree in a hexa world made of 6 triatree, return it's id surronded by the id of the triatree that are adjacent
fn hexa_near_triangle(current int) []int {
	if current == 0 {
		return [5, 0, 1]
	}
	if current == 5 {
		return [4, 5, 0]
	}
	return [current - 1, current, current + 1]
}

// for a considered pos, return if the triangle is pointing upward -> true, or downward -> false by default all triangle are considered pointing downward
fn check_reverse(coo []int) bool {
	mut is_reverse := false

	// len - 1 the last triangle doesn't interfet in it's own direction
	for elem in coo[..coo.len - 1] {
		if elem == 0 {
			is_reverse = !is_reverse
		}
	}
	return is_reverse
}

// check if the triatree can be merge -> if it as childs that all have the same compo
fn (tree Triatree) check_mergeable(parent Triatree_Ensemble) bool {
	match tree.compo {
		Childs {
			if parent.liste_tree[tree.compo.mid].compo != parent.liste_tree[tree.compo.up].compo {
				return false
			}
			if parent.liste_tree[tree.compo.mid].compo != parent.liste_tree[tree.compo.left].compo {
				return false
			}
			if parent.liste_tree[tree.compo.mid].compo != parent.liste_tree[tree.compo.right].compo {
				return false
			}
			return true
		}
		else {
			return false
		}
	}
}

// very usefull:
fn remove_from_base(base []int, liste []int) []int {
	mut final := []int{}
	for elem in base {
		mut not_private := true
		for privation in liste {
			if elem == privation {
				not_private = false
				break
			}
		}
		if not_private {
			final << [elem]
		}
	}
	return final
}
