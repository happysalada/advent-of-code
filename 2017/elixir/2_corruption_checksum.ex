defmodule Day2 do
  def part1(spreadsheet) do
    to_integer_list(spreadsheet)
    |> Enum.map(fn row -> Enum.max(row) - Enum.min(row) end)
    |> Enum.sum()
  end

  def part2(spreadsheet) do
    to_integer_list(spreadsheet)
    |> Enum.map(fn row -> Enum.sort(row) end)
    |> Enum.map(fn row -> find_multiples(row) end)
    |> Enum.sum()
  end

  defp to_integer_list(spreadsheet) do
    spreadsheet
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      String.split(row, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp find_multiples([head | tail]) do
    multiple =
      Enum.reduce(tail, nil, fn value, acc ->
        if rem(value, head) == 0,do: value, else: acc end)
    case multiple do
      nil -> find_multiples(tail)
      multiple -> div(multiple, head)
    end
  end
end
