defmodule Day3 do
  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
  end

  def includes({_number, origin_x, origin_y, width, height}, {x, y}) do
    origin_x <= x && origin_y <= y && origin_x + width > x && origin_y + height > y
  end

  def parse(claim) do
    claim
    |> String.split(["#", " @ ", ",", ": ", "x"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def claimed(claims) do
    claims
    |> Enum.reduce(%{}, fn {id, left, top, width, height}, claimed ->
      Enum.reduce((left + 1)..(left + width), claimed, fn x, claimed ->
        Enum.reduce((top + 1)..(top + height), claimed, fn y, claimed ->
          Map.update(claimed, {x, y}, [id], &[id | &1])
        end)
      end)
    end)
  end

  def claimed_once({id, left, top, width, height}, claimed) do
    Enum.all?((left + 1)..(left + width), fn x ->
      Enum.all?((top + 1)..(top + height), fn y ->
        Map.get(claimed, {x, y}) == [id]
      end)
    end)
  end

  def claimed_twice(claimed) do
    claimed
    |> Enum.filter(fn
      {_coord, [_, _ | _]} -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def run(input) do
    claims =
      input
      |> Enum.map(&parse/1)

    claimed = claimed(claims)

    claims
    |> Enum.find(&claimed_once(&1, claimed))
    |> IO.inspect()
  end

  def test() do
    File.read!("./test.txt")
    |> String.split("\n", trim: true)
  end
end

Day3.run(Day3.input())
