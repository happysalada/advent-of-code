defmodule Day3 do
  def part1(integer) do
    memory_coordinates()
    |> Stream.drop(integer - 2)
    |> Enum.take(1)
    |> hd()
    |> (fn %{x: x, y: y} -> abs(x) + abs(y) end).()
  end

  def part2(integer) do
    stress_test_values()
    |> Stream.drop_while(&(&1 <= integer))
    |> Enum.take(1)
    |> hd()
  end

  def stress_test_values() do
    Stream.transform(
      memory_coordinates(),
      %{%{x: 0, y: 0} => 1},
      fn location, memory ->
        value = Enum.sum(surrounding_values(memory, location))
        {[value], Map.put(memory, location, value)}
      end
    )
  end

  defp surrounding_values(memory, %{x: x, y: y}) do
    for x <- (x - 1)..(x + 1),
        y <- (y - 1)..(y + 1),
        {:ok, value} <- [Map.fetch(memory, %{x: x, y: y})],
        do: value
  end

  defp memory_coordinates(), do:
    path_coordinates(spiral_moves())

  defp path_coordinates(moves) do
    Stream.scan(
      moves,
      %{x: 0, y: 0},
      fn
        {:left, offset}, %{x: x, y: y} -> %{x: x - offset, y: y}
        {:right, offset}, %{x: x, y: y} -> %{x: x + offset, y: y}
        {:up, offset}, %{x: x, y: y} -> %{x: x, y: y + offset}
        {:down, offset}, %{x: x, y: y} -> %{x: x, y: y - offset}
      end
    )
  end

  defp spiral_moves(), do:
    Stream.resource(
      fn -> 1 end,
      fn size ->
        {
          [right: 1, up: size, left: size+1, down: size+1, right: size+1],
          size+2
        }
      end,
      fn _ -> :ok end
    )
    |> Stream.flat_map(fn {direction, steps} -> Stream.map(1..steps, fn _ -> {direction, 1} end) end)
end
