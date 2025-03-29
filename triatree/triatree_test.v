module triatree

@[assert_continues]
fn test_neighbors() {
	mut tree := Triatree{}
	for x in 0..4{
		for y in 0..4{
			for z in 0..4{
				assert tree.neighbors([x y z]).len == 3
			}
		}
	}
}