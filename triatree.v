module main

import math
import math.vec

const triabase = [0, 1, 2, 3]

type Self = Cara | Childs 

struct Triatree {
	mut:
	compo		Self	
	
	pos			[]int
	dimensions	int		// 0 le plus petit
}

struct Childs {
	mid	Triatree
	up	Triatree
	left	Triatree
	right	Triatree
}

struct Cara {
	// quantitées intensives
}


// coo tria_to_cart:
fn coo_tria_to_cart(pos []int, rota f32) vec.Vec2[f32]{
	mut position := vec.vec2[f32](0.0, 0.0)
	mut angle := rota
	for id in 0..pos.len{
		n := pos.len - 1 - id
		if pos[id] == 0{
			angle += math.pi
		}
		else{
			dist := f32(math.pow(2, n)/math.sqrt(3))
			// dist a vérif
			position += vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2(f32(0), f32(0)), angle + f32(pos[id] - 1)*math.pi*2/3)
		}
	}
	return position
}

fn hexa_world_coo_tri_to_cart(pos []int, current int) vec.Vec2[f32]{
	rota	:= f32(current)*math.pi/3
	// maybe need tp be fixed
	dist	:= f32(math.pow(2, pos.len)/math.sqrt(3))
	// dist a vérif
	coo_in_triangle :=  coo_tria_to_cart(pos, rota) + vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2(f32(0), f32(0)), rota)
	return coo_in_triangle
}

// coo cart_to_tria:
fn coo_cart_to_tria(pos vec.Vec2[f32]) []int{
	// to complete
	panic("Not completed")
	return [0]
}

fn hexa_world_coo_cart_to_tria(pos vec.Vec2[f32]) (int, []int){
	// to complete
	mut current := 0
	angle := pos.angle()
	for i in 0..6{
		if i*math.pi/3 <= angle && (i + 1)*math.pi/3 <= angle{
			current = i
			break
		}
	}
	rota	:= f32(current)*math.pi/3
	dist	:= f32(math.pow(2, pos.len)/math.sqrt(3))
	position := pos - vec.vec2[f32](dist, 0).rotate_around_ccw(vec.vec2(f32(0), f32(0)), rota)
	coo := coo_cart_to_tria(position)
	
	return current, coo
}

// neighbors
fn neighbors(pos []int) [][]int{
	n	:= pos.len
	mut nei	:= [][]int{}
	if pos[n-1] == 0{
		// 0 is the center of the triangle so it's neighbors can only be 1 2 3 of the same triangle
		for i in 1..4{
			nei << pos[..n-1]
			nei[nei.len-1] << [i]
		}
		return nei
	}

	nei << pos[..n-1]
	nei[0] << [0]
	mut to_ad := private(triabase, [0, pos[n-1]])

	// au sein du même triangle, le triangle {1, 2, 3} sera toujours opposé au triangle [0]x{1, 2, 3}, pour la même valeur
	// 1 out of 3
	mut first_stop := -1
	for tempo_id in 0..n{
		id 		:= n - tempo_id - 1
		if pos[id] != pos[n-1] && pos[id] != first_stop {
			if pos[id] == 0 && to_ad.len == 2{
				if pos == [0, 0, 1, 2]{panic(to_ad)}
				nei << pos[..id]
				nei[nei.len-1] << to_ad[0]
				nei[nei.len-1] << []int{len: tempo_id, init: to_ad[1]}
				
				nei << pos[..id]
				nei[nei.len-1] << to_ad[1]
				nei[nei.len-1] << []int{len: tempo_id, init: to_ad[0]}
				return nei
			}
			else{
				// pos[id] appartient a {1, 2, 3}\{pos[n-1]}
				if to_ad.len == 2{
					possible := private(to_ad, [pos[id]])
					if possible.len == 1{
						nei << pos[..id]
						nei[nei.len-1] << [0]
						nei[nei.len-1] << []int{len: tempo_id, init: possible[0]}

						to_ad = private(to_ad, possible)
						first_stop = pos[id]
					}
				}
				else if to_ad.len == 1{
					nei << pos[..id]
					mut orientation := [0]
					if pos[id] == 0{
						orientation = private(triabase, [0, pos[n-1], to_ad[0]])
					}
					nei[nei.len-1] << orientation

					new_base := private(triabase, [pos[id], orientation[0]])
					// new_base.len == 2 
					for finition in (id + 1)..n{
						nei[nei.len-1] << private(new_base, [pos[finition]])
					}
					
					return nei
				}
			}
		}
	}
	
	return nei
}

fn hexa_world_neighbors(pos []int, current int) ([]int, [][]int){
	if pos == []{
		near := hexa_near_triangle(current)
		return [near[0], near[2]], [[]int{}, []int{}]
	}

	mut directs_neighbors := neighbors(pos)

	if directs_neighbors.len == 1{
		if pos[0] == 1{
			directs_neighbors << []int{len: pos.len, init: 1}
			directs_neighbors << []int{len: pos.len, init: 1}
			// the order doesn't mater because they are all [1, 1, ..., 1]
			// this is the nearest of the center of the world
			return hexa_near_triangle(current), directs_neighbors
		}
	}
	if directs_neighbors.len <= 2{
		mut nei := []int{}
		possible := [2, 3]
		mut other := -1
		for id in 0..pos.len{
			if pos[id] == 1{
				nei << [1]
			}
			else{
				other = pos[id]
				nei << private(possible, [pos[id]])
			}
		}
		directs_neighbors << nei
		tria_nei := hexa_near_triangle(current)
		mut near := [tria_nei[1]]
		if other == 2{
			near << [tria_nei[2]]
		}
		else if other == 3{
			near << [tria_nei[1]]
		}
		return near , directs_neighbors
	}
	// else{panic("A 0 without 3 neigbors in it's base ??? pos: ${pos} current: ${current}")}
	// pos is inside a triangle
	return []int{len: 3, init: current}, directs_neighbors
}

// find
fn (tree Triatree) go_to(pos []int) &Triatree{
	if pos == tree.pos{
		return &tree
	}
	match tree.compo{
		Childs{
			if pos[0] == 0{
				return tree.compo.mid.go_to(pos[1..])
			}
			else if pos[0] == 1{
				return tree.compo.mid.go_to(pos[1..])
			}
			else if pos[0] == 2{
				return tree.compo.mid.go_to(pos[1..])
			}
			else if pos[0] == 3{
				return tree.compo.mid.go_to(pos[1..])
			}
		}
		else{}
	}
	return &tree
}

// divide & merge
enum Changement {
	divide
	merge
}

fn (mut tree Triatree) merge_divide(change Changement){
	match change{
		.divide{
			if tree.dimensions > 0{
				match tree.compo{
					Cara{
						mut pos_0 := tree.pos.clone()
						pos_0 << [0]
						mut pos_1 := tree.pos.clone()
						pos_1 << [1]
						mut pos_2 := tree.pos.clone()
						pos_2 << [2]
						mut pos_3 := tree.pos.clone()
						pos_3 << [3]
						tree.compo = Childs{
							mid	:	Triatree{compo: tree.compo, pos: pos_0, dimensions: (tree.dimensions - 1)}
							up	:	Triatree{compo: tree.compo, pos: pos_1, dimensions: (tree.dimensions - 1)}
							left:	Triatree{compo: tree.compo, pos: pos_2, dimensions: (tree.dimensions - 1)}
							right:	Triatree{compo: tree.compo, pos: pos_3, dimensions: (tree.dimensions - 1)}
						}
					}
					else{}
				}
			}
		}
		.merge{
			match tree.compo{
				Childs{
					// trouver parmis les childs si les cara sont les mêmes ?
				}
				else{}
			}
		}
	}
}

// utilitary
fn hexa_near_triangle(current int) []int{
	if current == 0{
		return [5, 0, 1]
	}
	if current == 5{
		return [4, 5, 0]
	}
	return [current - 1, current, current + 1]
}

// very usefull:
fn private(base []int, liste []int) []int{
	mut final := []int{}
	for elem in base{
		mut not_private := true
		for privation in liste{
			if elem == privation{
				not_private = false
				break
			}
		}
		if not_private{
			final << [elem]
		}
	}
	return final
}
