module triatree

type Self = Childs | Cara

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

fn (tree Triatree) neighbors(pos []int) []int{
	return []int{}
}
