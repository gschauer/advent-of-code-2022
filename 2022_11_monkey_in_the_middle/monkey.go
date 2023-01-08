package main

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"gopkg.in/yaml.v3"
)

// worryFunc determines the new worry level of an item.
type worryFunc func(w int) int

// ints is a type alias for simple int slices in YAML files.
type ints []int

// UnmarshalYAML converts a comma-separated list of numbers to an int slice.
func (is *ints) UnmarshalYAML(value *yaml.Node) error {
	return json.Unmarshal([]byte("["+value.Value+"]"), &is)
}

// cond is a type alias for numeric conditions.
type cond int

// UnmarshalYAML converts a textual condition to an int.
func (c *cond) UnmarshalYAML(value *yaml.Node) error {
	*c = cond(must(strconv.Atoi(strings.Split(value.Value, " ")[2])))
	return nil
}

// monkey represents a playful ape, who likes to throw items.
type monkey struct {
	Items   ints   `yaml:"Starting items"`
	Op      string `yaml:"Operation"`
	DivBy   cond   `yaml:"Test"`
	IfTrue  string `yaml:"If true"`
	IfFalse string `yaml:"If false"`
	nInsp   int    `yaml:"-"`
}

// inspect calculates the new worry level of an item.
// Then it rethrows it to another monkey based on the inherent condition.
func (m *monkey) inspect(idx int, wf worryFunc) int {
	m.nInsp++

	// calculate the new worry level as new=wf(op(old))
	expr := strings.SplitN(m.Op, "=", 2)[1]
	expr = strings.ReplaceAll(expr, "old", strconv.Itoa(m.Items[idx]))
	m.Items[idx] = wf(must(strconv.Atoi(calc(expr))))

	// determine the target monkey
	expr = fmt.Sprintf("%d %% %d == 0", m.Items[idx], m.DivBy)
	tgt := m.IfFalse
	if must(strconv.ParseBool(calc(expr))) {
		tgt = m.IfTrue
	}
	return must(strconv.Atoi(strings.Split(tgt, " ")[3]))
}
