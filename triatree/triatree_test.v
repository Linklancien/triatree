module triatree

@[assert_continues]
fn test_neighbors() {
	println("--------------------")
	println("test_neighbors():")
	mut tree := Triatree{}
	// Check for a triangle in the center of the hugest triangle => all have 3 neighbors
	print("test 1 center: ")
	for x in 0..4{
		for y in 0..4{
			for z in 0..4{
				// Check for the triangle in the center of a larger triangle
				pos := [0, x, y, z]
				nei := tree.neighbors(pos)
				// print de debug visuel:
				// print(pos)
				// print(" : ")
				// println(nei)
				// Only 3 triangle can be one's neighbor
				assert nei.len == 3 , 'assertion 1 failed for [0, x, y, z]: ${pos}'

				total := private(triabase, [z])
				mut ad := private(triabase, [z])
				for elem in nei{
					assert elem[elem.len-1] != z , 'assertion 2 failed for [0, x, y, z]: ${pos}, elem[elem.len-1]: ${elem[elem.len-1]}'
					assert elem.len == pos.len , 'assertion 3 failed for [0, x, y, z]: ${pos} : elem: ${elem}'
					for is_added in total{
						if is_added == elem[elem.len-1]{
							ad = private(ad, [elem[elem.len-1]])
						}
					}
				}
				// Check if this triangle has the other 3 coo in it's neigbor
				assert ad.len == 0 , 'assertion 4 failed for [0, x, y, z]: ${pos} : ad: ${ad}'
			}
		}
	}
	println("success")
	print("test 2 edges: ")
	// Check for a the edge of a triangle on the edge of the hugest
	for x in 1..4{
		for y in 1..4{
			pos := [x, y, y, y]
			nei := tree.neighbors(pos)
			if x == y{
				assert nei.len == 1 , 'assertion 1.1 failed for [0, x, y, z]: ${pos}'
			}
			else{
				assert nei.len == 2 , 'assertion 1.2 failed for [0, x, y, z]: ${pos}'
			}
		}
	}
	println("success")
	println("Passed")
	println("--------------------")
}

@[assert_continues]
fn test_private() {
	println("--------------------")
	println("test_private():")

	print("test 1 usefull: ")
	base := [0, 1, 2, 3]
	assert private(base, [0]) == [1, 2, 3] , 'assertion failed for specific: [0]'
	assert private(base, [1]) == [0, 2, 3] , 'assertion failed for specific: [1]'
	assert private(base, [2]) == [0, 1, 3] , 'assertion failed for specific: [2]'
	assert private(base, [3]) == [0, 1, 2] , 'assertion failed for specific: [3]'

	for i in 0..5{
		assert private(base, base[..i]).len == base.len - i , 'assertion failed for i: ${i}'
	}
	assert private(base, []).len == 4 , 'assertion failed for empty []'
	assert private(base, [5, 6, 7]).len == 4 , 'assertion failed for non in base [5, 6, 7]'
	assert private(base, [3, 3]).len == 3 , 'assertion failed for repetitive: [3, 3]'
	println("success")

	print("test 2 extension: ")
	n := 10
	ensemble := []int{len: n, init: index}
	for elem in ensemble{
		assert private(ensemble, [elem]).len == ensemble.len - 1 , 'assertion failed for elem: ${elem}'
	} 

	for i in 0..n{
		assert private(ensemble, ensemble[..i]).len == ensemble.len - i , 'assertion failed for i: ${i}'
	}
	println("success")

	println("Passed")
	println("--------------------")
}
