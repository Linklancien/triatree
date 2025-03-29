module triatree

// @[assert_continues]
fn test_neighbors() {
	println("test_neighbors():")
	mut tree := Triatree{}
	for x in 0..4{
		for y in 0..4{
			for z in 0..4{
				// Check for the triangle in the center of a larger triangle
				nei := tree.neighbors([0, x, y, z])
				assert nei.len == 3 , 'assertion 1 failed for [0, x, y, z]: ${[0, x, y, z]}'

				total := private(triabase, [z])
				mut ad := private(triabase, [z])
				for elem in nei{
					assert elem[elem.len-1] != z , 'assertion 2 failed for [0, x, y, z]: ${[0, x, y, z]}, elem[elem.len-1]: ${elem[elem.len-1]}'
					assert elem.len == 4 , 'assertion 3 failed for [0, x, y, z]: ${[0, x, y, z]} : elem: ${elem}'
					for is_added in total{
						if is_added == elem[elem.len-1]{
							ad = private(ad, [elem[elem.len-1]])
						}
					}
				}
				assert ad.len == 0 , 'assertion 4 failed for [0, x, y, z]: ${[0, x, y, z]} : ad: ${ad}'
			}
		}
	}
}

@[assert_continues]
fn test_private() {
	println("test_private():")
	base := [0, 1, 2, 3]

	assert private(base, [0]) == [1, 2, 3] , 'assertion failed for specific: [0]'
	assert private(base, [1]) == [0, 2, 3] , 'assertion failed for specific: [1]'
	assert private(base, [2]) == [0, 1, 3] , 'assertion failed for specific: [2]'
	assert private(base, [3]) == [0, 1, 2] , 'assertion failed for specific: [3]'

	for i in 0..5{
		assert private(base, base[..i]).len == base.len - i , 'assertion failed for i: ${i}'
	}
	assert private(base, []).len == 4 , 'assertion failed for []'
	assert private(base, [5, 6, 7]).len == 4 , 'assertion failed for [5, 6, 7]'
	assert private(base, [3, 3]).len == 3 , 'assertion failed for repetitive: [3, 3]'

}
