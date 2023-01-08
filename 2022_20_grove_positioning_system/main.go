package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"

	"golang.org/x/exp/slices"
)

func main() {
	key, rounds := 1, 1
	in := "input.txt"
	if len(os.Args) > 1 {
		in = os.Args[1]
	}
	if len(os.Args) > 2 {
		key = must(strconv.Atoi(os.Args[2]))
	}
	if len(os.Args) > 3 {
		rounds = must(strconv.Atoi(os.Args[3]))
	}

	f := must(os.Open(in))
	defer func() { _ = f.Close() }()

	var is []int
	var vs []int
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		is = append(is, len(is))
		vs = append(vs, must(strconv.Atoi(sc.Text()))*key)
	}

	for r := 0; r < rounds; r++ {
		for n := 0; n < len(vs); n++ {
			for q := 0; q < len(vs); q++ {
				if is[q] == n {
					move(is, q, vs[n])
					break
				}
			}
		}
	}

	a := vs[is[(1000%len(vs))]]
	b := vs[is[(2000%len(vs))]]
	c := vs[is[(3000%len(vs))]]
	fmt.Printf("%d+%d+%d=%d\n", a, b, c, a+b+c)
}

func move(is []int, idx int, offset int) {
	if offset == 0 {
		return
	}

	n := len(is)
	pos := (offset + (n - 1)) % (n - 1)
	from, to := idx, (idx+pos)%(n-1)
	if to <= 0 {
		to += n - 1
	}

	e := is[from]
	is = slices.Delete(is, from, from+1)
	is = slices.Insert(is, to, e)
}

func must[T any](t T, err error) T {
	if err != nil {
		panic(err)
	}
	return t
}
