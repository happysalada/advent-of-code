defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

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
    |> Enum.sort_by(&elem(&1, 0), &(NaiveDateTime.compare(&1, &2) == :lt))
    |> Enum.reduce({%{}, nil}, fn
      {_naive_datetime, guard_number, _}, {asleep_map, _} ->
        {asleep_map, guard_number}

      {naive_datetime, :asleep}, {asleep_map, guard_number} ->
        {asleep_map, guard_number, naive_datetime}

      {naive_datetime, :awake}, {asleep_map, guard_number, asleep_start} ->
        current_asleep =
          asleep_start.minute..(naive_datetime.minute - 1)
          |> Enum.map(&{&1, 1})
          |> Enum.into(%{})

        {Map.update(
           asleep_map,
           guard_number,
           current_asleep,
           &Map.merge(&1, current_asleep, fn _k, v1, v2 -> v1 + v2 end)
         ), guard_number}
    end)
    |> (&elem(&1, 0)).()
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
    |> Enum.sort_by(&elem(&1, 0), &(NaiveDateTime.compare(&1, &2) == :lt))
    |> Enum.reduce({%{}, nil}, fn
      {_naive_datetime, guard_number, _}, {asleep_map, _} ->
        {asleep_map, guard_number}

      {naive_datetime, :asleep}, {asleep_map, guard_number} ->
        {asleep_map, guard_number, naive_datetime}

      {naive_datetime, :awake}, {asleep_map, guard_number, asleep_start} ->
        current_asleep =
          asleep_start.minute..(naive_datetime.minute - 1)
          |> Enum.map(&{&1, 1})
          |> Enum.into(%{})

        {Map.update(
           asleep_map,
           guard_number,
           current_asleep,
           &Map.merge(&1, current_asleep, fn _k, v1, v2 -> v1 + v2 end)
         ), guard_number}
    end)
    |> (&elem(&1, 0)).()
    |> Enum.map(fn {guard_number, asleep_map} ->
      {minute, times} = asleep_map |> Enum.max_by(&elem(&1, 1))
      {guard_number, minute, times}
    end)
    |> Enum.max_by(&elem(&1, 2))
    |> (&(elem(&1, 0) * elem(&1, 1))).()
    |> IO.inspect()
  end

  def parse_entry(log_entry) do
    log_entry
    |> String.split(["[", "] "], trim: true)
    |> List.to_tuple()
    |> raw_to_entry()
  end

  def raw_to_entry({datetime, "wakes up"}) do
    {string_to_date(datetime), :awake}
  end

  def raw_to_entry({datetime, "falls asleep"}) do
    {string_to_date(datetime), :asleep}
  end

  def raw_to_entry({datetime, begins_shift}) do
    [guard_number] = String.split(begins_shift, ["Guard #", " begins shift"], trim: true)

    {string_to_date(datetime), String.to_integer(guard_number), :begins_shift}
  end

  def string_to_date(
        <<year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), " ",
          hour::binary-size(2), ":", minute::binary-size(2)>>
      ) do
    NaiveDateTime.new(
      String.to_integer(year),
      String.to_integer(month),
      String.to_integer(day),
      String.to_integer(hour),
      String.to_integer(minute),
      0
    )
    |> (&elem(&1, 1)).()
  end

  def max_minute(asleep_map) do
    asleep_map |> Enum.max_by(&elem(&1, 1)) |> (&elem(&1, 0)).()
  end
end
