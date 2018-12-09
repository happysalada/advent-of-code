defmodule Day15 do
  require Bitwise

  def part1(a, b) do
    judge(40_000_000, a, b, &rem(&1 * 16807, 2147483647), &rem(&1 * 48271, 2147483647), 0)
  end

  def part2(a, b) do
    judge(5_000_000, a, b, &find_next_factor(&1, 16807, 4), &find_next_factor(&1, 48271, 8), 0)
  end

  defp judge(0, _a, _b, _generator_a, _generator_b, count), do: count
  defp judge(steps, a, b, generator_a, generator_b, count) do
    a = generator_a.(a)
    b = generator_b.(b)
    count = if Bitwise.band(a, 0xFFFF) == Bitwise.band(b, 0xFFFF), do: count + 1, else: count
    judge(steps-1, a, b, generator_a, generator_b, count)
  end

  def find_next_factor(x, multiplier, factor_of) do
    x = rem(x * multiplier, 2147483647)
    if rem(x, factor_of) == 0, do: x, else: find_next_factor(x, multiplier, factor_of)
  end
end
