use std::collections::HashSet;
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
  let mut freq = 0;
  for line in input.lines() {
    let change: i32 = line.parse()?;
    freq += change;
  }
  println!("{}", freq);
  Ok(())
}

fn part2(input: &str) -> Result<()> {
  let mut freq = 0;
  let mut seen = HashSet::new();
  seen.insert(0);
  loop {
    for line in input.lines() {
      let change: i32 = line.parse()?;
      freq += change;
      if seen.contains(&freq) {
        println!("{}", freq);
        return Ok(());
      }
      seen.insert(freq);
    }
  }
}
