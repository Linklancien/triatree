module triatree

type Self = Childs | Cara

struct Triatree {
	compo	Self	
	
	pos		[]int{}
	dimensions	int		// 0 le plus petit
}

struct Childs {
	0	Triatree
	1	Triatree
	2	Triatree
	3	Triatree
}

enum Cara {
	
}

fn (tree Triatree) neighbors() []int{}{
	return []int{}
}
