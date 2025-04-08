module main

// @[assert_continues]
fn test_neighbors() {
	println('--------------------')
	println('test_neighbors():')
	mut tree := Triatree{}

	// Check for a triangle in the center of the hugest triangle => all have 3 neighbors
	print('test 1 center: ')
	for x in 0 .. 4 {
		for y in 0 .. 4 {
			for z in 0 .. 4 {
				// Check for the triangle in the center of a larger triangle
				pos := [0, x, y, z]
				nei := neighbors(pos)

				// print de debug visuel:
				// print(pos)
				// print(" : ")
				// println(nei)
				// Only 3 triangle can be one's neighbor
				assert nei.len == 3, 'assertion 1 failed for [0, x, y, z]: ${pos}'
				total := remove_from_base(triabase, [z])
				mut ad := remove_from_base(triabase, [z])
				for elem in nei {
					assert elem[elem.len - 1] != z, 'assertion 2 failed for [0, x, y, z]: ${pos}, elem[elem.len-1]: ${elem[elem.len - 1]}'
					assert elem.len == pos.len, 'assertion 3 failed for [0, x, y, z]: ${pos} : elem: ${elem}'
					for is_added in total {
						if is_added == elem[elem.len - 1] {
							ad = remove_from_base(ad, [elem[elem.len - 1]])
						}
					}
				}

				// Check if this triangle has the other 3 coo in it's neighbor
				assert ad.len == 0, 'assertion 4 failed for [0, x, y, z]: ${pos} : ad: ${ad}'
			}
		}
	}
	println('success')
	print('test 2 edges: ')

	// Check for a the edge of a triangle on the edge of the hugest
	for x in 1 .. 4 {
		for y in 1 .. 4 {
			pos := [x, y, y, y]
			nei := neighbors(pos)
			if x == y {
				assert nei.len == 1, 'assertion 1.1 failed for [0, x, y, z]: ${pos}'
			} else {
				assert nei.len == 2, 'assertion 1.2 failed for [0, x, y, z]: ${pos}'
			}
		}
	}
	println('success')
	print('test 3 is nei of nei: ')

	// try := [[0, 1, 1, 2], [0, 0, 0, 0], [0, 1, 1, 1], [3, 1, 2, 3]]
	// for elem in try{
	for x in 0 .. 4 {
		for y in 0 .. 4 {
			for z in 0 .. 4 {
				for t in 0 .. 4 {
					elem := [x, y, z, t]
					nei := neighbors(elem)
					mut is_nei := [][]int{}
					for to_check in nei {
						test := neighbors(to_check)

						// println("")
						// print("$to_check: ")
						// println(test)
						for current in test {
							if current == elem {
								is_nei << to_check
								break
							}
						}
					}
					assert is_nei.len == nei.len, 'assertion 1 failed for [...] = ${elem}: \n ${is_nei} alors que ${nei}'
				}
			}
		}
	}
	println('success')
	println('Passed')
	println('--------------------')
}

fn test_hexa_world_neighbors() {
	println('--------------------')
	println('test_hexa_world_neighbors():')

	print('test 1 specifics cases: ')
	near_null, nei_null := hexa_world_neighbors([]int{}, 1)
	assert near_null.len == 2, 'assertion failed for specific: []'
	assert near_null[0] != near_null[1], 'assertion failed for specific: []'
	assert nei_null.len == 2, 'assertion failed for specific: []'
	println('success')

	print('test 2 insides cases: ')
	for x in 0 .. 4 {
		for y in 0 .. 4 {
			pos := [0, x, y]
			near, nei := hexa_world_neighbors(pos, 1)
			assert near.len == 3, 'assertion failed for specific: []'
			assert nei.len == 3, 'assertion failed for specific: []'
			also_nei := neighbors(pos)
			assert nei == also_nei, 'assertion failed for specific: [] \n ${nei} != ${also_nei}'
		}
	}
	println('success')
	print('test 3 edge cases: ')
	for cur in 1 .. 7 {
		for t in 1 .. 3 {
			for aff in [1, t] {
				for aff_sec in [1, t] {
					pos := [t, aff, aff_sec]
					near, nei := hexa_world_neighbors(pos, 1)
					mut count := 0
					for n in near {
						if n != cur {
							count += 1
						}
					}
					assert count >= 1, 'assertion failed for edge: ${pos} \n ${near} == ${cur}'
				}
			}
		}
	}
	println('success')

	println('Passed')
	println('--------------------')
}

@[assert_continues]
fn test_remove_from_base() {
	println('--------------------')
	println('test_private():')

	print('test 1 usefull: ')
	base := [0, 1, 2, 3]
	assert remove_from_base(base, [0]) == [1, 2, 3], 'assertion failed for specific: [0]'
	assert remove_from_base(base, [1]) == [0, 2, 3], 'assertion failed for specific: [1]'
	assert remove_from_base(base, [2]) == [0, 1, 3], 'assertion failed for specific: [2]'
	assert remove_from_base(base, [3]) == [0, 1, 2], 'assertion failed for specific: [3]'

	for i in 0 .. 5 {
		assert remove_from_base(base, base[..i]).len == base.len - i, 'assertion failed for i: ${i}'
	}
	assert remove_from_base(base, []).len == 4, 'assertion failed for empty []'
	assert remove_from_base(base, [5, 6, 7]).len == 4, 'assertion failed for non in base [5, 6, 7]'
	assert remove_from_base(base, [3, 3]).len == 3, 'assertion failed for repetitive: [3, 3]'
	println('success')

	print('test 2 extension: ')
	n := 10
	ensemble := []int{len: n, init: index}
	for elem in ensemble {
		assert remove_from_base(ensemble, [elem]).len == ensemble.len - 1, 'assertion failed for elem: ${elem}'
	}

	for i in 0 .. n {
		assert remove_from_base(ensemble, ensemble[..i]).len == ensemble.len - i, 'assertion failed for i: ${i}'
	}
	println('success')

	println('Passed')
	println('--------------------')
}
