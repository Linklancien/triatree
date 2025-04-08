module main

import math
import math.vec
import rand

const triabase = [0, 1, 2, 3]

type Self = Cara | Childs

struct Triatree {
mut:
	compo Self

	pos        []int
	dimensions int
	// 0 le plus petit
}

struct Childs {
	mid   Triatree
	up    Triatree
	left  Triatree
	right Triatree
}

struct Cara {
	// quantitées intensives
}

fn coo_tria_to_cart(pos []int, rota f32) vec.Vec2[f32] {
	mut position := vec.vec2[f32](0.0, 0.0)
	mut angle := rota
	for id in 0 .. pos.len {
		n := pos.len - 1 - id
		if pos[id] == 0 {
			angle += math.pi
		} else {
			position += vec.vec2[f32](f32(math.pow(2, n) * math.sqrt(3) / 6), 0).rotate_around_ccw(vec.vec2(f32(0),
				f32(0)), angle + f32(pos[id] - 1) * math.pi * 2 / 3)

			// Distance a vérif
		}
	}
	return position
}

fn coo_cart_to_tria(pos vec.Vec2[f32]) []int {
	// to complete
	panic('Not completed')
	return [0]
}

// NEIGHBORS:

fn neighbors(pos []int) [][]int {
	n := pos.len
	mut nei := [][]int{}
	if pos[n - 1] == 0 {
		// 0 is the center of the triangle so it's neighbors can only be 1 2 3 of the same triangle
		for i in 1 .. 4 {
			nei << pos[..n - 1]
			nei[nei.len - 1] << [i]
		}
		return nei
	}

	nei << pos[..n - 1]
	nei[0] << [0]
	mut to_ad := remove_from_base(triabase, [0, pos[n - 1]])

	// au sein du même triangle, le triangle {1, 2, 3} sera toujours opposé au triangle [0]x{1, 2, 3}, pour la même valeur
	// 1 out of 3
	mut first_stop := -1
	for tempo_id in 0 .. n {
		id := n - tempo_id - 1
		if pos[id] != pos[n - 1] && pos[id] != first_stop {
			if pos[id] == 0 && to_ad.len == 2 {
				if pos == [0, 0, 1, 2] {
					panic(to_ad)
				}
				nei << pos[..id]
				nei[nei.len - 1] << to_ad[0]
				nei[nei.len - 1] << []int{len: tempo_id, init: to_ad[1]}

				nei << pos[..id]
				nei[nei.len - 1] << to_ad[1]
				nei[nei.len - 1] << []int{len: tempo_id, init: to_ad[0]}
				return nei
			} else {
				// pos[id] appartient a {1, 2, 3}\{pos[n-1]}
				if to_ad.len == 2 {
					possible := remove_from_base(to_ad, [pos[id]])
					if possible.len == 1 {
						nei << pos[..id]
						nei[nei.len - 1] << [0]
						nei[nei.len - 1] << []int{len: tempo_id, init: possible[0]}

						to_ad = remove_from_base(to_ad, possible)
						first_stop = pos[id]
					}
				} else if to_ad.len == 1 {
					nei << pos[..id]
					mut orientation := [0]
					if pos[id] == 0 {
						orientation = remove_from_base(triabase, [0, pos[n - 1], to_ad[0]])
					}
					nei[nei.len - 1] << orientation

					new_base := remove_from_base(triabase, [pos[id], orientation[0]])

					// new_base.len == 2
					for finition in (id + 1) .. n {
						nei[nei.len - 1] << remove_from_base(new_base, [pos[finition]])
					}

					return nei
				}
			}
		}
	}

	return nei
}

fn hexa_world_neighbors(pos []int, current int) ([]int, [][]int) {
	if pos == [] {
		near := hexa_near_triangle(current)
		return [near[0], near[2]], [[]int{}, []int{}]
	}

	mut directs_neighbors := neighbors(pos)

	if directs_neighbors.len == 1 {
		if pos[0] == 1 {
			directs_neighbors << []int{len: pos.len, init: 1}
			directs_neighbors << []int{len: pos.len, init: 1}

			// the order doesn't mater because they are all [1, 1, ..., 1]
			// this is the nearest of the center of the world
			return hexa_near_triangle(current), directs_neighbors
		}
	}
	if directs_neighbors.len <= 2 {
		mut nei := []int{}
		possible := [2, 3]
		mut other := -1
		for id in 0 .. pos.len {
			if pos[id] == 1 {
				nei << [1]
			} else {
				other = pos[id]
				nei << remove_from_base(possible, [pos[id]])
			}
		}
		directs_neighbors << nei
		tria_nei := hexa_near_triangle(current)
		mut near := [tria_nei[1]]
		if other == 2 {
			near << [tria_nei[2]]
		} else if other == 3 {
			near << [tria_nei[1]]
		}
		return near, directs_neighbors
	}

	// else{panic("A 0 without 3 neigbors in it's base ??? pos: ${pos} current: ${current}")}
	// pos is inside a triangle
	return []int{len: 3, init: current}, directs_neighbors
}

// follow the path in the triatree while the childs exist
fn (tree Triatree) go_to(pos []int) &Triatree {
	if pos == tree.pos {
		return &tree
	}
	match tree.compo {
		Childs {
			if pos[0] == 0 {
				return tree.compo.mid.go_to(pos[1..])
			} else if pos[0] == 1 {
				return tree.compo.mid.go_to(pos[1..])
			} else if pos[0] == 2 {
				return tree.compo.mid.go_to(pos[1..])
			} else if pos[0] == 3 {
				return tree.compo.mid.go_to(pos[1..])
			}
		}
		else {}
	}
	return &tree
}

// PHYSIC:

// take a position, and a corner toward is applied the gravity and return the next likely position
fn gravity(pos []int, center int) []int {
	n := pos.len

	is_reverse := check_reverse(pos)

	// next position:

	// check if the current pos is at the gravity center
	mut is_center := true
	for i in 0 .. n {
		id := n - i - 1
		if pos[id] != center {
			is_center = false
			break
		}
	}

	if is_center {
		return pos
	}

	nei := neighbors(pos)
	mut next := pos[..n - 1].clone()
	if is_reverse {
		if pos[n - 1] == 0 {
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
		} else if pos[n - 1] == center {
			next << 0
		} else {
			final_co := remove_from_base(triabase, [0, center, pos[n - 1]])[0]
			for elem in nei {
				if elem[n - 1] == final_co {
					next = elem.clone()
					break
				}
			}
		}
	} else {
		if pos[n - 1] == 0 {
			next << center
		} else if pos[n - 1] == center {
			next_final_nei := remove_from_base(triabase, [0, center])

			if nei.len == 2 {
				// in this case there is only one of the two neighbors wich is closer to the center of gravity
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

// divide & merge:

fn (mut tree Triatree) divide() {
	if tree.dimensions > 0 {
		match tree.compo {
			Cara {
				mut pos_0 := tree.pos.clone()
				pos_0 << [0]
				mut pos_1 := tree.pos.clone()
				pos_1 << [1]
				mut pos_2 := tree.pos.clone()
				pos_2 << [2]
				mut pos_3 := tree.pos.clone()
				pos_3 << [3]
				tree.compo = Childs{
					mid:   Triatree{
						compo:      tree.compo
						pos:        pos_0
						dimensions: (tree.dimensions - 1)
					}
					up:    Triatree{
						compo:      tree.compo
						pos:        pos_1
						dimensions: (tree.dimensions - 1)
					}
					left:  Triatree{
						compo:      tree.compo
						pos:        pos_2
						dimensions: (tree.dimensions - 1)
					}
					right: Triatree{
						compo:      tree.compo
						pos:        pos_3
						dimensions: (tree.dimensions - 1)
					}
				}
			}
			else {}
		}
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
fn check_reverse(pos []int) bool {
	mut is_reverse := false

	// len - 1 the last triangle doesn't interfet in it's own direction
	for elem in pos[..pos.len - 1] {
		if elem == 0 {
			is_reverse = !is_reverse
		}
	}
	return is_reverse
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
