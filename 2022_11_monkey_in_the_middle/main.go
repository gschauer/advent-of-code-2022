// Package main analyzes the monkey business.
//
// The input is almost in YAML format, except:
//   - int arrays are not enclosed in brackets.
//     This was achieved by letting []int implement yaml.Unmarshaler.
//   - "Test" is not an object, so "If true" / "If false" are converted to
//     properties by removing indentation.
//
// Then, any YAML parser can unmarshal the input to a map of monkeys.
//
// Mathematical expressions could have been parsed in a similar way.
// Instead, I decided to showcase a (probably) slower dynamic computation
// leveraging Go's parser and type system (see types.Eval).
package main

import (
	"bytes"
	"fmt"
	"go/token"
	"go/types"
	"io"
	"os"
	"sort"
	"strconv"

	"gopkg.in/yaml.v3"
)

func main() {
	f := must(os.Open("input.txt"))
	defer func() { _ = f.Close() }()
	y := must(io.ReadAll(f))
	y = bytes.ReplaceAll(y, []byte("    "), []byte("  "))

	// part 1
	ms := observeMonkeys(bytes.NewBuffer(y))
	play(ms, 20, func(w int) int { return w / 3 })

	// part 2
	ms = observeMonkeys(bytes.NewBuffer(y))
	maxWorry := teamUp(ms)
	play(ms, 10000, func(w int) int { return w % maxWorry })
}

// play let the monkey rethrow their items n times.
// The worry level of an item after careful inspection is modified by the given
// worry function.
func play(ms []*monkey, n int, wf worryFunc) {
	for r := 0; r < n; r++ {
		for _, m := range ms {
			for idx := range m.Items {
				next := m.inspect(idx, wf)
				n := ms[next]
				n.Items = append(n.Items, m.Items[idx])
			}
			m.Items = ints{}
		}
	}

	var inspects []int
	for _, m := range ms {
		inspects = append(inspects, m.nInsp)
	}
	sort.Sort(sort.Reverse(sort.IntSlice(inspects)))
	fmt.Println("Monkey Business:", inspects[0]*inspects[1])
}

// calc evaluates the given Go expression.
func calc(expr string) string {
	fs := token.NewFileSet()
	tv := must(types.Eval(fs, nil, token.NoPos, expr))
	return tv.Value.ExactString()
}

// observeMonkeys unmarshalls the given YAML input to a bunch of monkeys.
func observeMonkeys(r io.Reader) (ms []*monkey) {
	d := yaml.NewDecoder(r)
	var mByName map[string]*monkey
	mustNoErr(d.Decode(&mByName))

	for i := 0; i < len(mByName); i++ {
		ms = append(ms, mByName["Monkey "+strconv.Itoa(i)])
	}
	return
}

// teamUp calculates the maximum worry level with regard to the test condition
// of all monkeys.
func teamUp(ms []*monkey) int {
	var max = 1
	for _, m := range ms {
		max *= int(m.DivBy)
	}
	return max
}

// must panics if err is null. Otherwise, t is returned.
func must[T any](t T, err error) T {
	mustNoErr(err)
	return t
}

// mustNoErr panics if err is null.
func mustNoErr(err error) {
	if err != nil {
		panic(err)
	}
}
