defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

  import NimbleParsec

  def input() do
    File.read!("./input.txt")
  end

  @doc """
  Hello world.
  """
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_entry/1)
    |> Enum.sort()
    |> minutes_asleep()
    |> Enum.map(fn {guard_number, asleep_map} ->
      {guard_number, Map.values(asleep_map) |> Enum.sum(), max_minute(asleep_map)}
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> (&(elem(&1, 0) * elem(&1, 2))).()
    |> IO.inspect()
  end

  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_entry/1)
    |> Enum.sort()
    |> minutes_asleep()
    |> Enum.map(fn {guard_number, asleep_map} ->
      {minute, times} = asleep_map |> Enum.max_by(&elem(&1, 1))
      {guard_number, minute, times}
    end)
    |> Enum.max_by(&elem(&1, 2))
    |> (&(elem(&1, 0) * elem(&1, 1))).()
    |> IO.inspect()
  end

  def minutes_asleep(logs) do
    {asleep_map, _} =
      logs
      |> Enum.reduce({%{}, nil}, fn
        {_date, _hour, _minute, {:shift, guard_number}}, {asleep_map, _} ->
          {asleep_map, guard_number}

        {_date, _hour, minute, :sleeps}, {asleep_map, guard_number} ->
          {asleep_map, guard_number, minute}

        {_date, _hour, end_minute, :wakes_up}, {asleep_map, guard_number, asleep_start} ->
          current_asleep =
            asleep_start..(end_minute - 1)
            |> Enum.map(&{&1, 1})
            |> Enum.into(%{})

          {Map.update(
             asleep_map,
             guard_number,
             current_asleep,
             &Map.merge(&1, current_asleep, fn _k, v1, v2 -> v1 + v2 end)
           ), guard_number}
      end)

    asleep_map
  end

  def parse_entry(log_entry) do
    {:ok, [year, month, day, hour, minute, state], _, _, _, _} =
      log_entry
      |> parse_log()

    {{year, month, day}, hour, minute, state}
  end

  defparsecp(
    :parse_log,
    ignore(string("["))
    |> integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string(" "))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string("] "))
    |> choice([
      ignore(string("Guard #"))
      |> integer(min: 1)
      |> ignore(string(" begins shift"))
      |> unwrap_and_tag(:shift),
      ignore(string("falls asleep")) |> replace(:sleeps),
      ignore(string("wakes up")) |> replace(:wakes_up)
    ])
  )

  def max_minute(asleep_map) do
    asleep_map |> Enum.max_by(&elem(&1, 1)) |> (&elem(&1, 0)).()
  end
end
