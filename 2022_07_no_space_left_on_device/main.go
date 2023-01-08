package main

import (
	"bufio"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"testing/fstest"
)

const tot = 70000000
const req = 30000000

var reFileInfo = regexp.MustCompilePOSIX(`[0-9]+ .+`)

func main() {
	r := must(os.Open("input.txt"))
	defer func() { _ = r.Close() }()

	fsInfo := stat(buildFS(r))

	// part 1
	sum := int64(0)
	for _, s := range fsInfo {
		if s <= 100000 {
			sum += s
		}
	}
	fmt.Println("Small:", sum)

	// part 2
	used := fsInfo["."]
	want := int(used - tot + req)
	fmt.Println("Need:", want)

	// since the paths are not needed anymore, the sizes are dumped into a slice
	var es []int
	for _, s := range fsInfo {
		es = append(es, int(s))
	}
	// use binary search to find the smallest size, where size >= want
	sort.Ints(es)
	x, _ := sort.Find(len(es), func(i int) int {
		return want - es[i] - 1
	})
	fmt.Println("Deleted:", es[x])
}

// buildFS reads commands and their output from the given Reader and creates
// an in-memory copy of the filesystem. Files are allocated in their full size
// and contain only blanks.
func buildFS(r io.Reader) fstest.MapFS {
	var cwd = "/"
	var vfs = fstest.MapFS{
		".": &fstest.MapFile{Mode: 0777 | os.ModeDir},
	}

	for sc := bufio.NewScanner(r); sc.Scan(); {
		l := sc.Text()

		switch {
		case strings.HasPrefix(l, "$ cd "):
			n := strings.TrimPrefix(l, "$ cd ")
			cwd = path.Clean(path.Join(cwd, n))
		case l == "$ ls":
			// intentionally do nothing
			break
		case strings.HasPrefix(l, "dir "):
			n := strings.TrimPrefix(l, "dir ")
			mkdir(vfs, path.Join(cwd, n))
		case reFileInfo.MatchString(l):
			s, n, _ := strings.Cut(l, " ")
			write(vfs, path.Join(cwd, n), must(strconv.Atoi(s)))
		default:
			panic(l)
		}
	}
	return vfs
}

// mkdir creates a new directory, if it does not exist yet.
func mkdir(vfs fstest.MapFS, n string) {
	n = strings.TrimPrefix(n, "/")
	if _, ok := vfs[n]; !ok {
		vfs[n] = &fstest.MapFile{Mode: 0777 | os.ModeDir}
	}
}

// write creates a new file with the given size.
// Existing files are overwritten.
func write(vfs fstest.MapFS, n string, s int) {
	vfs[strings.TrimPrefix(n, "/")] = &fstest.MapFile{
		Data: make([]byte, s),
		Mode: 0666,
	}
}

// stat walks the file tree and collects the total size of directory contents.
func stat(vfs fstest.MapFS) map[string]int64 {
	sizes := map[string]int64{}
	mustNoErr(fs.WalkDir(vfs, ".", func(p string, d fs.DirEntry, err error) error {
		if fi := must(d.Info()); fi.Mode().IsRegular() {
			for p = path.Dir(p); p != "."; p = path.Dir(p) {
				sizes[p] += fi.Size()
			}
			sizes[p] += fi.Size()
		}
		return err
	}))
	return sizes
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
