module triatree

import math
import math.vec

const triabase = [0, 1, 2, 3]

type Self = Cara | Childs 

struct Triatree {
	compo	Self	
	
	pos		[]int
	dimensions	int		// 0 le plus petit
}

struct Childs {
	center	Triatree
	up		Triatree
	left	Triatree
	right	Triatree
}

struct Cara {
	
}

fn coo_tria_to_cart(pos []int, rota f32) vec.Vec2[f32]{
	mut position := vec.vec2[f32](0.0, 0.0)
	mut angle := rota
	for id in 0..pos.len{
		n := pos.len - 1 - id
		if pos[id] == 0{
			angle += math.pi
		}
		else{
			position += vec.vec2[f32](f32(math.pow(2, n)*math.sqrt(3)/6), 0).rotate_around_ccw(vec.vec2(f32(0), f32(0)), angle + f32(pos[id] - 1)*math.pi*2/3)
			// Distance a vérif
		}
	}
	return position
}

// neighbors
fn (tree Triatree) neighbors(pos []int) [][]int{
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
	if pos[n-1] != pos[n-2]{
		// au sein du même triangle, le triangle {1, 2, 3} sera toujours opposé au triangle [0]x{1, 2, 3}, pour la même valeur
		nei << pos[..n-2]
		nei[nei.len-1] << [0]
		nei[nei.len-1] << [pos[n-2]]
		to_ad = private(to_ad, [pos[n-2]])
		// 1 out of 3

		mut all := [0]
		all << pos[n-1]
		all << pos[n-2]
		high := private(triabase, all)
		for id_r in 1..pos.len{
			id := pos.len - id_r - 1
			if pos[id] == 0{
				nei << pos[..(id)]
				nei[nei.len-1] << high

				mut tempo_fix := private(triabase, [0])
				tempo_fix = private(tempo_fix, high)
				for i in (id + 1)..(pos.len - 1){
					tempo := private(tempo_fix, [pos[i]])
					nei[nei.len-1] << tempo
				}

				nei[nei.len-1] << to_ad
				break
			}
		}
	}
	else if pos[n-1] == pos[n-2]{
		
	}
	
	return nei
}

fn (tree Triatree) hexa_world_neighbors(pos []int, current int) ([]int, [][]int){
	mut directs_neighbors := tree.neighbors(pos)

	if directs_neighbors.len == 2{
		if pos[0] == 2{

		}
		if pos[0] == 3{
			
		}
	}
	else if directs_neighbors.len == 1{
		if pos[0] == 1{
			directs_neighbors << []int{len: pos.len, init: 1}
			directs_neighbors << []int{len: pos.len, init: 1}
			// the order doesn't mater because they are all [1, 1, ..., 1]
			// this is the nearest of the center of the world
			return hexa_near_triangle(current), directs_neighbors
		}
	}
	// pos is inside a triangle
	return []int{len: 3, init: current}, directs_neighbors
}

fn hexa_near_triangle(current int) []int{
	if current == 1{
		return [6, 1, 2]
	}
	if current == 6{
		return [5, 6, 1]
	}
	return [current - 1, current, current + 1]
}

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
