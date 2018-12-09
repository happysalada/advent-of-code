use std::collections::HashMap;
use std::fs::File;
use std::io::prelude::*;

type Result<T> = ::std::result::Result<T, Box<::std::error::Error>>;

fn main() -> Result<()> {
  let mut file = File::open("./input.txt")?;
  let mut input = String::new();
  file.read_to_string(&mut input)?;
  part1(&input)?;
  part2(&input)?;
  Ok(())
}

fn part1(input: &str) -> Result<()> {
  let mut doubles = 0;
  let mut triples = 0;
  for line in input.lines() {
    let mut letters: HashMap<char, i32> = HashMap::new();
    for ch in line.chars() {
      let counter = letters.entry(ch).or_insert(0);
      *counter += 1;
    }
    if letters.values().any(|&x| x == 2) {
      doubles += 1;
    }
    if letters.values().any(|&x| x == 3) {
      triples += 1;
    }
  }
  println!("{}", doubles * triples);
  Ok(())
}

fn part2(input: &str) -> Result<()> {
  for line in input.lines() {
    if let Some(similar) = input.lines().find(|other| is_similar(line, other)) {
      let answer: String = line
        .chars()
        .zip(similar.chars())
        .filter(|(a, b)| a == b)
        .map(|(a, _b)| a)
        .collect();
      println!("{}", answer);
      return Ok(());
    }
  }
  Ok(())
}

fn is_similar(first: &str, second: &str) -> bool {
  let differences: i32 = first
    .chars()
    .zip(second.chars())
    .map(|(a, b)| if a == b { return 0 } else { return 1 })
    .sum();
  differences == 1
}
