# My [Advent of Code](https://adventofcode.com/) Solutions

## Why Bash?

Many people claim that Bash is not a good scripting language.
Although, it is available on any Unix system and essential for many CI/CD pipelines.
Since it is my favorite scripting language, I took the challenge and implemented most Advent of Code exercises in Bash.

As a matter of fact, Bash has some limitations e.g., no floating point numbers, no multi-dimensional arrays and no sets.
Moreover, there are countless [pitfalls](https://mywiki.wooledge.org/BashPitfalls), which can lead to terrible mistakes.

However, there are some aspects, where Bash really shines e.g.,
[string manipulation](https://tldp.org/LDP/abs/html/string-manipulation.html),
[command substitution](https://tldp.org/LDP/abs/html/commandsub.html) as well as
[builtins](https://www.man7.org/linux/man-pages/man1/bash.1.html) for reading files to arrays, and more.
Additionally, tools like
[`grep`](https://man7.org/linux/man-pages/man1/grep.1.html),
[`sed`](https://man7.org/linux/man-pages/man1/sed.1.html),
[`cut`](https://man7.org/linux/man-pages/man1/cut.1.html) or
[`paste`](https://man7.org/linux/man-pages/man1/paste.1.html)
enable concise Bash scripts where general purpose programming languages require multiple statements.

For example, the first exercise implemented in Java would be something like:

```java
int max = 0, curr = 0;
for (var l : Files.readAllLines(Paths.get("input.txt"))) {
    if (l.isEmpty()) {
        max = Math.max(max, curr);
        curr = 0;
    } else {
        curr += Integer.parseInt(l);
    }
}
System.out.println(max);
```

The same can be achieved in Bash with the following code:

```bash
paste -sd + input.txt | sed -E 's/\+\+/\n/g' | bc | sort -r | head -n 1 
```

At the first glance, this seems to be a cryptic command.
However, it's pretty straightforward if you break it down piece by piece.

```bash
paste -sd + input.txt |  # concatenate all lines into a single line, replace '\n' with '+'
  sed -E 's/\+\+/\n/g' | # occurrences of "++" means there was an empty line => split them again
  bc |                   # now we have lines like "1+2+3", bc sums up the values in each line
  sort -r |              # sort the resulting sums in descending order
  head -n 1              # pick the first one - the maximum value
```

## Test-Driven Development (TDD)

Besides implementing the exercises, I intended to apply good engineering practices such as TDD.
For some exercises, I used [bash_unit](https://github.com/pgrange/bash_unit) to write assertions before writing code.
You might know [bats](https://github.com/sstephenson/bats), which was the most popular test framework for Bash scripts.
bash_unit is an amazing framework, which can even fake external commands to provide the desired output.
Moreover, bash_unit tests are ordinary shell scripts, which makes it easy to write tests and maintain them.

## Status

- [`25 * ` Full of Hot Air](../../tree/main/2022_25_full_of_hot_air)
- `24   ` Blizzard Basin
- `23   ` Unstable Diffusion
- `22   ` Monkey Map
- [`21 **` Monkey Math](../../tree/main/2022_21_monkey_math)
- [`20 **` Grove Positioning System](../../tree/main/2022_20_grove_positioning_system)
- `19   ` Not Enough Minerals
- [`18 **` Boiling Boulders](../../tree/main/2022_18_boiling_boulders)
- `17   ` Pyroclastic Flow
- `16   ` Proboscidea Volcanium
- `15   ` Beacon Exclusion Zone
- [`14 **` Regolith Reservoir](../../tree/main/2022_14_regolith_reservoir)
- [`13 **` Distress Signal](../../tree/main/2022_13_distress_signal)
- [`12 **` Hill Climbing Algorithm](../../tree/main/2022_12_hill_climbing_algorithm)
- [`11 **` Monkey in the Middle](../../tree/main/2022_11_monkey_in_the_middle)
- [`10 **` Cathode-Ray Tube](../../tree/main/2022_10_cathode_ray_tube)
- [` 9 **` Rope Bridge](../../tree/main/2022_09_rope_bridge)
- [` 8 **` Treetop Tree House](../../tree/main/2022_08_treetop_tree_house)
- [` 7 **` No Space Left On Device](../../tree/main/2022_07_no_space_left_on_device)
- [` 6 **` Tuning Trouble](../../tree/main/2022_06_tuning_trouble)
- [` 5 **` Supply Stacks](../../tree/main/2022_05_supply_stacks)
- [` 4 **` Camp Cleanup](../../tree/main/2022_04_camp_cleanup)
- [` 3 **` Rucksack Reorganization](../../tree/main/2022_03_rucksack_reorganization)
- [` 2 **` Rock Paper Scissors](../../tree/main/2022_02_rock_paper_scissors)
- [` 1 **` Calorie Counting](../../tree/main/2022_01_calorie_counting)
