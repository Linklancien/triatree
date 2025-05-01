module main

import math

fn test_coos() {
	println('--------------------')
	println('test_coos():')

	print('test 1 bijection:')
	for x in 0 .. 4 {
		for y in 0 .. 4 {
			for z in 0 .. 4 {
				coo := [x, y, z]
				pos := coo_tria_to_cart(coo, 0, coo.len)
				new_coo := coo_cart_to_tria(pos, coo.len)
				new_pos := coo_tria_to_cart(new_coo, 0, coo.len)

				assert coo == new_coo, 'assertion failed: coo ${coo}, pos ${pos}, new_coo ${new_coo}, new_pos ${new_pos} '
				assert pos == new_pos, 'assertion failed: \n coo ${coo} \n pos.magnitude() ${pos.magnitude()} \n pos ${pos} \n new_coo ${new_coo} \n new_pos.magnitude() ${new_pos.magnitude()} \n new_pos ${new_pos} '
				assert pos.magnitude() == new_pos.magnitude(), 'assertion failed: coo ${coo}, pos ${pos}, new_coo ${new_coo}, new_pos ${new_pos} '
			}
		}
	}
	println('success')
	print('test 2 hugest bijection:')
	for x in 0 .. 4 {
		for y in 0 .. 4 {
			for z in 0 .. 4 {
				for r in 0 .. 4 {
					for s in 0 .. 4 {
						for t in 0 .. 4 {
							coo := [x, y, z, r, s, t]
							pos := coo_tria_to_cart(coo, 0, coo.len)
							new_coo := coo_cart_to_tria(pos, coo.len)
							new_pos := coo_tria_to_cart(new_coo, 0, coo.len)

							assert coo == new_coo, 'assertion failed: coo ${coo}, pos ${pos}, new_coo ${new_coo}, new_pos ${new_pos} '
							assert pos == new_pos, 'assertion failed: \n coo ${coo} \n pos.magnitude() ${pos.magnitude()} \n pos ${pos} \n new_coo ${new_coo} \n new_pos.magnitude() ${new_pos.magnitude()} \n new_pos ${new_pos} '
							assert pos.magnitude() == new_pos.magnitude(), 'assertion failed: coo ${coo}, pos ${pos}, new_coo ${new_coo}, new_pos ${new_pos} '
						}
					}
				}
			}
		}
	}
	println('success')

	println('Passed')
	println('--------------------')
}

fn test_hexa_world_coos() {
	println('--------------------')
	println('test_hexa_world_neighbors():')

	print('test 1 bijection:')
	for c in 0 .. 6 {
		for x in 0 .. 4 {
			for y in 0 .. 4 {
				for z in 0 .. 4 {
					coo := [x, y, z]
					pos := hexa_world_coo_tria_to_cart(coo, c, coo.len)
					new_coo, new_c := hexa_world_coo_cart_to_tria(pos, coo.len)
					new_pos := hexa_world_coo_tria_to_cart(new_coo, new_c, coo.len)

					assert coo == new_coo, 'assertion failed: \n coo ${coo}, c ${c} \n pos.magnitude() ${pos.magnitude()} \n pos ${pos} \n new_coo ${new_coo}, new_c ${new_c} \n new_pos.magnitude() ${new_pos.magnitude()} \n new_pos ${new_pos} '
					assert pos == new_pos, 'assertion failed: \n coo ${coo}, c ${c} \n pos.magnitude() ${pos.magnitude()} \n pos ${pos} \n new_coo ${new_coo}, new_c ${new_c} \n new_pos.magnitude() ${new_pos.magnitude()} \n new_pos ${new_pos} '
					assert pos.magnitude() == new_pos.magnitude(), 'assertion failed: \n coo ${coo}, c ${c} \n pos.magnitude() ${pos.magnitude()} \n pos ${pos} \n new_coo ${new_coo}, new_c ${new_c} \n new_pos.magnitude() ${new_pos.magnitude()} \n new_pos ${new_pos} '
					assert c == new_c, 'assertion failed c: ${c}, new_c: ${new_c}'
				}
			}
		}
	}

	println('Passed')
	println('--------------------')
}

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

fn test_gravity() {
	println('--------------------')
	println('test_gravity():')

	print('test 1 special case: ')
	assert gravity([0], 1) == [[1]], 'assertion failed for specific: [0]'
	assert gravity([1], 1) == [], 'assertion failed for specific: [1]'
	assert gravity([2], 1) == [[0]], 'assertion failed for specific: [2]'
	assert gravity([3], 1) == [[0]], 'assertion failed for specific: [3]'
	println('success')

	print('test 2 one [x], differents centers: ')
	for gravity_center in 1 .. 3 {
		assert gravity([0], gravity_center) == [[gravity_center]], 'assertion failed for specific: [0], gravity_center: ${gravity_center}'
		assert gravity([gravity_center], gravity_center) == [], 'assertion failed for specific: [gravity_center], gravity_center: ${gravity_center}'
		others := remove_from_base([1, 2, 3], [gravity_center])
		assert gravity([others[0]], gravity_center) == [[0]], 'assertion failed for specific: [0], gravity_center: ${gravity_center}, others: ${others[0]}'
		assert gravity([others[1]], gravity_center) == [[0]], 'assertion failed for specific: [0], gravity_center: ${gravity_center}, others: ${others[1]}'
	}
	println('success')

	print('test 3 more [x, y, z]: ')
	for gravity_center in 1 .. 3 {
		for x in 0 .. 3 {
			for y in 0 .. 3 {
				for z in 0 .. 3 {
					coo := [x, y, z]
					n := coo.len
					is_reverse := check_reverse(coo)
					liste_next := gravity(coo, gravity_center)
					nei := neighbors(coo)

					assert liste_next.len <= 2, 'assertion failed for lens : liste_next: ${liste_next},  coo: ${coo},  gravity_center: ${gravity_center}'

					for next in liste_next {
						assert next.len == coo.len, 'assertion failed for lens : liste_next: ${liste_next},  coo: ${coo},  gravity_center: ${gravity_center}'
					}
					if z == gravity_center {
						if x == z && y == z {
							assert liste_next == [], 'assertion failed for lens : liste_next: ${liste_next},  coo: ${coo},  gravity_center: ${gravity_center}'
						} else if is_reverse {
							assert liste_next[0][n - 1] == 0, 'assertion failed for lens : liste_next: ${liste_next},  coo: ${coo},  gravity_center: ${gravity_center}'
						}
					}
					if z == 0 {
						if is_reverse {
							assert liste_next.len == 2, 'assertion failed for lens : liste_next: ${liste_next},  coo: ${coo},  gravity_center: ${gravity_center}'
						} else {
							assert liste_next.len == 1, 'assertion failed for lens : liste_next: ${liste_next},  coo: ${coo},  gravity_center: ${gravity_center}'
						}
					}
				}
			}
		}
	}
	println('success')

	println('Passed')
	println('--------------------')
}

fn test_change_elements() {
	println('--------------------')
	println('test_change_elements():')
	mut tria_ensemble := Triatree_Ensemble{
		liste_tree: []Triatree{len: 1, init: Triatree{
			compo:     Elements.wood
			id:        index
			dimension: 8
			coo:       []
		}}
	}

	print('test 1 special case: ')
	tria_ensemble.liste_tree[0].change_elements(Elements.stone, mut tria_ensemble)
	match tria_ensemble.liste_tree[0].compo {
		Elements {
			assert tria_ensemble.liste_tree[0].compo == Elements.stone
		}
		else {}
	}
	tria_ensemble.liste_tree[0].change_elements(Elements.water, mut tria_ensemble)
	match tria_ensemble.liste_tree[0].compo {
		Elements {
			assert tria_ensemble.liste_tree[0].compo == Elements.water
		}
		else {}
	}
	println('success')

	tria_ensemble = Triatree_Ensemble{
		liste_tree: []Triatree{len: 1, init: Triatree{
			compo:     Elements.wood
			id:        index
			dimension: 8
			coo:       []
		}}
	}
	tria_ensemble.liste_tree[0].divide(mut tria_ensemble)

	print('test 2 recursiv: ')
	tria_ensemble.liste_tree[0].change_elements(Elements.stone, mut tria_ensemble)

	match tria_ensemble.liste_tree[0].compo {
		Childs {
			indexs := [tria_ensemble.liste_tree[0].compo.mid, tria_ensemble.liste_tree[0].compo.up,
				tria_ensemble.liste_tree[0].compo.left, tria_ensemble.liste_tree[0].compo.right]
			for index in indexs {
				match tria_ensemble.liste_tree[index].compo {
					Elements {
						assert tria_ensemble.liste_tree[index].compo == Elements.stone
					}
					else {}
				}
			}
		}
		else {}
	}
	println('success')

	println('Passed')
	println('--------------------')
}

fn test_init_ensemble_divide() {
	println('--------------------')
	println('test_init_ensemble_divide():')

	println('test 1 special case: ')
	tria_ensemble_test := Triatree_Ensemble{
		liste_tree: init_ensemble_divide(3, 1, Elements.water)
	}
	assert tria_ensemble_test.liste_tree.len == 5, 'assertion failed len incorrect'
	println('success')

	println('test 2 rec: ')
	mut len := 0
	for i in 0 .. 3 {
		len += int(math.pow(4, i))
		tria_ensemble := Triatree_Ensemble{
			liste_tree: init_ensemble_divide(3, i, Elements.water)
		}
		assert tria_ensemble.liste_tree.len == len, 'assertion failed len incorrect'
	}
	println('success')

	println('Passed')
	println('--------------------')
}

fn test_index_to_coo() {
	println('--------------------')
	println('test_check_reverse():')

	println('test 1 special case: ')
	assert index_to_coo(0) == []
	assert index_to_coo(1) == [0]
	assert index_to_coo(2) == [1]
	assert index_to_coo(3) == [2]
	assert index_to_coo(4) == [3]
	assert index_to_coo(5) == [0, 0]
	assert index_to_coo(6) == [0, 1]
	assert index_to_coo(7) == [0, 2]
	assert index_to_coo(8) == [0, 3]
	assert index_to_coo(9) == [1, 0]
	assert index_to_coo(10) == [1, 1]
	assert index_to_coo(11) == [1, 2]
	assert index_to_coo(12) == [1, 3]
	assert index_to_coo(13) == [2, 0]
	assert index_to_coo(14) == [2, 1]
	assert index_to_coo(15) == [2, 2]
	assert index_to_coo(16) == [2, 3]
	assert index_to_coo(17) == [3, 0]
	assert index_to_coo(18) == [3, 1]
	assert index_to_coo(19) == [3, 2]
	assert index_to_coo(20) == [3, 3]
	println('success')

	println('Passed')
	println('--------------------')
}

fn test_divide_and_merge() {
	println('--------------------')
	println('test_divide_and_merge():')

	print('test 1 in ensemble: ')
	mut ensemble := Triatree_Ensemble{
		liste_tree: []Triatree{len: 1, init: Triatree{
			compo:     Elements.wood
			id:        index
			dimension: 8
			coo:       []
		}}
	}
	for i in 0 .. 5 {
		if i % 2 == 0 {
			ensemble.divide(0)
			assert ensemble.liste_tree[0].compo.type_name() == 'Childs', 'assertion failed for divide; ensemble.liste_tree[0] have wrong name ensemble: ${ensemble}'
			assert ensemble.liste_tree.len == 5, 'assertion failed for divide not enough triatree in ensemble.liste_tree: ${ensemble.liste_tree.len} expected: 5 '
			assert ensemble.free_index.len == 0, 'assertion failed for divide not enough triatree in ensemble.free_index: ${ensemble.free_index.len} expected: 0 '
			assert ensemble.liste_tree[0].check_mergeable(ensemble) == true, 'assertion failed after being divide tree is not mergeable'
		} else {
			ensemble.merge(0)
			assert ensemble.liste_tree[0].compo.type_name() == 'Elements', 'assertion failed for merge; ensemble.liste_tree[0] have wrong name ensemble: ${ensemble}'
			assert ensemble.free_index.len == 4, 'assertion failed for merge not enough triatree in ensemble.free_index: ${ensemble.free_index.len} expected: $4 '
		}
	}
	println('success')

	print('test 2 free liste no empty:')
	mut indexs := []int{}
	for i in 1 .. 4 {
		indexs << [i]
		ensemble = Triatree_Ensemble{
			free_index: indexs
			liste_tree: []Triatree{len: 1 + i, init: Triatree{
				compo:     Elements.wood
				id:        index
				dimension: 8
				coo:       []
			}}
		}
		ensemble.divide(0)
		assert ensemble.liste_tree[0].compo.type_name() == 'Childs', 'assertion failed for divide; ensemble.liste_tree[0] have wrong name ensemble: ${ensemble}'
		assert ensemble.liste_tree.len == 5, 'assertion failed for divide not enough triatree in ensemble.liste_tree: ${ensemble.liste_tree.len} expected: 5 '
		assert ensemble.free_index.len == 0, 'assertion failed for divide not enough triatree in ensemble.free_index: ${ensemble.free_index.len} expected: 0 '
		assert ensemble.liste_tree[0].check_mergeable(ensemble) == true, 'assertion failed after being divide tree is not mergeable'
	}
	println('success')

	print('test 3 free liste len > 4:')
	indexs = [1, 2, 3, 4]
	for i in 5 .. 8 {
		indexs << [i]
		ensemble = Triatree_Ensemble{
			free_index: indexs
			liste_tree: []Triatree{len: 5 + i, init: Triatree{
				compo:     Elements.wood
				id:        index
				dimension: 8
				coo:       []
			}}
		}
		ensemble.divide(0)
		assert ensemble.liste_tree[0].compo.type_name() == 'Childs', 'assertion failed for ${i}; ensemble.liste_tree[0] have wrong name ensemble: ${ensemble}'
		assert ensemble.liste_tree.len == (5 + i), 'assertion failed for ${i} not enough triatree in ensemble.liste_tree: ${ensemble.liste_tree.len} expected: (5 + i): ${
			5 + i} '

		assert ensemble.free_index.len == (i - 4), 'assertion failed for ${i} not enough triatree in ensemble.free_index: ${ensemble.free_index.len} expected: ${i} '
		assert ensemble.liste_tree[0].check_mergeable(ensemble) == true, 'assertion failed for ${i} tree is not mergeable'
	}
	println('success')

	print('test 4 in hexa_world: ')
	mut hexa_world := Hexa_world{
		world: [6]Triatree_Ensemble{init: Triatree_Ensemble{
			liste_tree: []Triatree{len: 1, init: Triatree{
				compo:     Elements.wood
				id:        index
				dimension: 8
				coo:       []
			}}
		}}
	}

	for i in 0 .. 5 {
		if i % 2 == 0 {
			hexa_world.divide(0)
			for ens in hexa_world.world {
				assert ens.liste_tree[0].compo.type_name() == 'Childs', 'assertion failed for divide; ens.liste_tree[0] have wrong name ens: ${ens}'
				assert ens.liste_tree.len == 5, 'assertion failed for divide not enough triatree in ens.liste_tree: ${ens.liste_tree.len} expected: 5 '
				assert ens.free_index.len == 0, 'assertion failed for divide not enough triatree in ens.free_index: ${ens.free_index.len} expected: 0 '
				assert ens.liste_tree[0].check_mergeable(ens) == true, 'assertion failed after being divide tree is not mergeable'
			}
		} else {
			hexa_world.merge(0)
			for ens in hexa_world.world {
				assert ens.liste_tree[0].compo.type_name() == 'Elements', 'assertion failed for merge; ens.liste_tree[0] have wrong name ens: ${ens}'
				assert ens.free_index.len == 4, 'assertion failed for merge not enough triatree in ens.free_index: ${ens.free_index.len} expected: $4 '
			}
		}
	}
	println('success')

	println('Passed')
	println('--------------------')
}

// utilitary
fn test_check_reverse() {
	println('--------------------')
	println('test_check_reverse():')

	print('test 1 special case: ')
	assert check_reverse([0]) == false, 'assertion failed for specific: [0]'
	assert check_reverse([0, 2]) == true, 'assertion failed for specific: [0]'
	assert check_reverse([0, 0, 0]) == false, 'assertion failed for specific: [0]'
	println('success')

	print('test 2: ')
	mut test := [0]
	mut value := false
	for _ in 0 .. 3 {
		assert check_reverse(test) == value, 'assertion failed for specific: [0]'
		test << [0]
		value = !value
	}
	println('success')

	println('Passed')
	println('--------------------')
}

fn test_remove_from_base() {
	println('--------------------')
	println('test_remove_from_base():')

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
