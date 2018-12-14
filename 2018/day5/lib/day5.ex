defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """

  def input() do
    File.read!("./input.txt")
    |> String.trim()
  end

  @doc """
  Hello world.

  ## Examples

      iex> Day5.react("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

  """
  def react(polymer) do
    polymer
    |> to_charlist()
    |> react([])
  end

  def react([letter1 | rest], [letter2 | rest_acc]) when abs(letter1 - letter2) == 32,
    do: react(rest, rest_acc)

  def react([letter1 | rest], acc), do: react(rest, [letter1 | acc])

  def react([], codepoints), do: codepoints |> Enum.reverse() |> List.to_string()

  @doc """
  part 2

  ## Examples

      iex> Day5.part2("dabAcCaCBAcCcaDA")
      4

  """
  def part2(polymer) do
    Enum.map(65..90, fn codepoint ->
      polymer
      |> to_charlist()
      |> Enum.filter(&(&1 != codepoint && &1 != codepoint + 32))
      |> react([])
      |> byte_size()
    end)
    |> Enum.min()
  end
end
