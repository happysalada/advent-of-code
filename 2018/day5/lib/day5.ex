defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """

  def input() do
    File.read!("./input.txt")
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

  def react([letter1 | rest], acc) do
    IO.inspect(letter1)
    react(rest, [letter1 | acc])
  end

  def react([], codepoints), do: codepoints |> Enum.reverse() |> List.to_string()
end
