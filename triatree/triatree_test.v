module triatree

@[assert_continues]
fn test_neighbors() {
	println("test_neighbors():")
	mut tree := Triatree{}
	for x in 0..4{
		for y in 0..4{
			for z in 0..4{
				assert tree.neighbors([x, y, z]).len == 3 , 'assertion failed for [x, y, z]: ${[x, y, z]}'
			}
		}
	}
}

@[assert_continues]
fn test_private() {
	println("test_private():")
	base := [0, 1, 2, 3]
	for i in 0..5{
		assert private(base, base[..i]).len == 4 - i , 'assertion failed for i: ${i}'
	}
	assert private(base, []).len == 4 , 'assertion failed for []'
	assert private(base, [5, 6, 7]).len == 4 , 'assertion failed for [5, 6, 7]'
	assert private(base, [3, 3]).len == 3 , 'assertion failed for repetitive: [3, 3]'
}
