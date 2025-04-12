module main

import math
import math.vec

const triabase = [0, 1, 2, 3]
const dimensions_max = 3

type Self = Cara | Childs

struct Triatree {
mut:
	compo Self

	coo       []int
	dimension int
	// entre dimensions_max et 0
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

// COO TRIA TO CART:

fn coo_tria_to_cart(coo []int, rota f32) vec.Vec2[f32] {
	mut position := vec.vec2[f32](0.0, 0.0)
	mut angle := rota
	for id in 0 .. coo.len {
		n := coo.len - 1 - id
		dist := f32(math.pow(2, n - 1) / math.sqrt(3))
		if coo[id] == 0 {
			angle += math.pi
		} else if coo[id] == 1 {
			position += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0),
				f32(0)), angle - math.pi / 2)
		} else if coo[id] == 2 {
			position += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0),
				f32(0)), angle + math.pi / 6)
		} else if coo[id] == 3 {
			position += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0),
				f32(0)), angle + math.pi * 5 / 6)
		}
	}
	return position
}

fn coo_cart_corners(coo []int, rota f32) (vec.Vec2[f32], vec.Vec2[f32], vec.Vec2[f32]) {
	center_pos := coo_tria_to_cart(coo, rota)
	mut angle := rota
	for id in 0 .. coo.len {
		if coo[id] == 0 {
			angle += math.pi
		}
	}
	dist := f32(math.pow(2, dimensions_max - coo.len) / math.sqrt(3))
	pos1 := center_pos +
		vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0), f32(0)), angle +
		math.pi * 3 / 2)
	pos2 := center_pos +
		vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0), f32(0)), angle + math.pi / 6)
	pos3 := center_pos +
		vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0), f32(0)), angle +
		math.pi * 5 / 6)
	return pos1, pos2, pos3
}

fn hexa_world_coo_tria_to_cart(coo []int, current int) vec.Vec2[f32] {
	rota := f32(current) * math.pi / 3 + math.pi / 6
	dist := f32(math.pow(2, coo.len) / math.sqrt(3))
	coo_in_triangle := (coo_tria_to_cart(coo, rota) + vec.vec2[f32](dist, 0)).rotate_around_ccw(vec.vec2[f32](f32(0),
		f32(0)), rota)
	return coo_in_triangle
}

// COO CART TO TRIA:

fn coo_cart_to_tria(pos vec.Vec2[f32], dimension int) []int {
	// at the start the child 1 of hugest triangle is pointing downward
	if dimension == -1 {
		return []int{}
	}

	abs_x := math.pow(2, dimension)

	// using math:
	// check if the position is inside the triangle
	ratio_out := pos.y / math.sqrt(3) + abs_x / 3
	if pos.y >= abs_x / (2 * math.sqrt(3)) || pos.x > ratio_out || -pos.x > ratio_out {
		// panic('Not in trianlge dim: $dimension, \n pos: $pos \n ${pos.y >= abs_x /(2* math.sqrt(3))} \n ${pos.x > ratio_out} \n ${-pos.x > ratio_out}')
		return []int{}
	}

	// check in wich chil of the triangle is the position
	mut coo := 0
	ratio_in := pos.y / math.sqrt(3) - abs_x / 6
	if pos.y <= -abs_x / (4 * math.sqrt(3)) {
		coo = 1
	} else if pos.x < ratio_in {
		coo = 3
	} else if -pos.x < ratio_in {
		coo = 2
	} else {
		coo = 0
	}

	// compute ce position of the child compare of the center of the current triangle
	mut actual_pos := vec.vec2[f32](f32(0), f32(0))
	dist := f32(math.pow(2, dimension - 1) / math.sqrt(3))
	if coo == 1 {
		actual_pos += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0), f32(0)),
			-math.pi / 2)
	} else if coo == 2 {
		actual_pos += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0), f32(0)),
			math.pi / 6)
	} else if coo == 3 {
		actual_pos += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2[f32](f32(0), f32(0)),
			math.pi * 5 / 6)
	}

	// compute the position relative to the child center 
	mut previous_pos := pos - actual_pos

	// rotate the position if the triangle is upside down == the child is 0
	if coo == 0 {
		previous_pos = previous_pos.rotate_around_cw(vec.vec2[f32](f32(0), f32(0)),
			math.pi)
	}

	mut final_coo := [coo]
	final_coo << coo_cart_to_tria(previous_pos, dimension - 1)
	return final_coo
}

fn hexa_world_coo_cart_to_tria(pos vec.Vec2[f32], dimension_precision int) ([]int, int) {
	// to complete
	mut current := 0
	angle := pos.angle()
	for i in 0 .. 6 {
		if i * math.pi / 3 <= angle && (i + 1) * math.pi / 3 <= angle {
			current = i
			break
		}
	}

	rota := f32(current) * math.pi / 3
	dist := f32(math.pow(2, dimension_precision) / math.sqrt(3))
	position := pos.rotate_around_cw(vec.vec2[f32](f32(0), f32(0)), rota) - vec.vec2[f32](dist, 0)
	coo := coo_cart_to_tria(position, dimension_precision)

	return coo, current
}

// NEIGHBORS:

fn neighbors(coo []int) [][]int {
	n := coo.len
	mut nei := [][]int{}
	if coo[n - 1] == 0 {
		// 0 is the center of the triangle so it's neighbors can only be 1 2 3 of the same triangle
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

			// the order doesn't mater because they are all [1, 1, ..., 1]
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
			near << [tria_nei[2]]
		} else if other == 3 {
			near << [tria_nei[1]]
		}
		return near, directs_neighbors
	}

	// else{panic("A 0 without 3 neigbors in it's base ??? coo: ${coo} current: ${current}")}
	// coo is inside a triangle
	return []int{len: 3, init: current}, directs_neighbors
}

// find
fn (tree Triatree) go_to(coo []int) &Triatree {
	if coo == tree.coo {
		return &tree
	}
	match tree.compo {
		Childs {
			if coo[0] == 0 {
				return tree.compo.mid.go_to(coo[1..])
			} else if coo[0] == 1 {
				return tree.compo.mid.go_to(coo[1..])
			} else if coo[0] == 2 {
				return tree.compo.mid.go_to(coo[1..])
			} else if coo[0] == 3 {
				return tree.compo.mid.go_to(coo[1..])
			}
		}
		else {}
	}
	return &tree
}

// divide & merge
enum Changement {
	divide
	merge
}

fn (mut tree Triatree) merge_divide(change Changement) {
	match change {
		.divide {
			if tree.dimension > 0 {
				match tree.compo {
					Cara {
						mut pos_0 := tree.coo.clone()
						pos_0 << [0]
						mut pos_1 := tree.coo.clone()
						pos_1 << [1]
						mut pos_2 := tree.coo.clone()
						pos_2 << [2]
						mut pos_3 := tree.coo.clone()
						pos_3 << [3]
						tree.compo = Childs{
							mid:   Triatree{
								compo:     tree.compo
								coo:       pos_0
								dimension: (tree.dimension - 1)
							}
							up:    Triatree{
								compo:     tree.compo
								coo:       pos_1
								dimension: (tree.dimension - 1)
							}
							left:  Triatree{
								compo:     tree.compo
								coo:       pos_2
								dimension: (tree.dimension - 1)
							}
							right: Triatree{
								compo:     tree.compo
								coo:       pos_3
								dimension: (tree.dimension - 1)
							}
						}
					}
					else {}
				}
			}
		}
		.merge {
			match tree.compo {
				Childs {
					// trouver parmis les childs si les cara sont les mêmes ?
				}
				else {}
			}
		}
	}
}

// utilitary
fn hexa_near_triangle(current int) []int {
	if current == 0 {
		return [5, 0, 1]
	}
	if current == 5 {
		return [4, 5, 0]
	}
	return [current - 1, current, current + 1]
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
