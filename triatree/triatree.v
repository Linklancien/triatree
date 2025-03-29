module triatree

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
	if pos[n-1] != pos[n-2]{

	}
	if pos[n-1] == pos[n-2]{}
	return nei
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
