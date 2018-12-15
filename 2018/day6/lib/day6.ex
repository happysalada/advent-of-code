defmodule Day6 do
  @moduledoc """
  Documentation for Day6.
  """

  @doc """
  compute the largest finite area

  ## Examples

      iex> Day6.largest_area([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}])
      17

  """
  def largest_area(points) do
    infinites = infinites(points)

    points
    |> grid()
    |> closest_for(points)
    |> Enum.reduce(%{}, fn
      {_point, closest_point}, acc ->
        if is_nil(closest_point) || closest_point in infinites do
          acc
        else
          Map.update(acc, closest_point, 1, &(&1 + 1))
        end
    end)
    |> max_area()
  end

  @doc """
  calculates the max x and y coordianates in a list of points

  ## Examples

      iex> Day6.grid([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}])
      {1..8, 1..9}

  """
  def grid(points) do
    {{min_x, _}, {max_x, _}} = points |> Enum.min_max_by(&elem(&1, 0))
    {{_, min_y}, {_, max_y}} = points |> Enum.min_max_by(&elem(&1, 1))
    {min_x..max_x, min_y..max_y}
  end

  @doc """
  closest of the given points for each coordinate inside the given range
  """
  def closest_for({x_range, y_range}, points) do
    for x <- x_range, y <- y_range, do: {{x, y}, closest({x, y}, points)}, into: %{}
  end

  @doc """
  calculates the minimum distance between a point and a list of points

  ## Examples

      iex> Day6.closest({0, 0}, [{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}])
      {1, 1}

  """
  def closest(point, points) do
    points
    |> Enum.map(&{manhattan(&1, point), &1})
    |> Enum.sort()
    |> case do
      [{distance, _}, {distance, _} | _] ->
        nil

      [{_distance, coordinate} | _] ->
        coordinate
    end
  end

  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  @doc """
  filters the points for which the area is infinite

  ## Examples

      iex> Day6.infinites([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}])
      #MapSet<[{1, 1}, {1, 6}, {8, 3}, {8, 9}]>

  """
  def infinites(points) do
    {min_x..max_x, min_y..max_y} = grid = grid(points)
    closest_map = closest_for(grid, points)

    infinite_for_x = for x <- min_x..max_x, y <- [min_y, max_y], do: closest_map[{x, y}]
    infinite_for_y = for x <- [min_x, max_x], y <- min_y..max_y, do: closest_map[{x, y}]

    (infinite_for_x ++ infinite_for_y)
    |> Enum.filter(& &1)
    |> MapSet.new()
  end

  @doc """
  gives the maximum area for a set of points and their area

  ## Examples

      iex> Day6.max_area(%{{3, 4} => 9, {5, 5} => 17})
      17

  """
  def max_area(area_map) do
    {_max_point, max_area} =
      area_map
      |> Enum.max_by(fn {_point, count} -> count end)

    max_area
  end

  @doc """
  provides the input
  """
  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.map(fn coords ->
      [x, y] = String.split(coords, ", ", trim: true)
      {String.to_integer(x), String.to_integer(y)}
    end)
  end

  @doc """
  return the area where all the distance to all the points is under

  ## Examples

      iex> Day6.area_under([{1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9}], 32)
      16

  """
  def area_under(points, max_dist) do
    points
    |> grid()
    |> sum_distance_less_than(points, max_dist)
    |> Enum.count()
  end

  @doc """
  returns the sum of the distance to the given points for each point of the grid
  """
  def sum_distance_less_than({x_range, y_range}, points, max_dist) do
    for x <- x_range,
        y <- y_range,
        point = {x, y},
        sum_distance(point, points) < max_dist,
        do: {x, y}
  end

  def sum_distance(point, points) do
    points
    |> Enum.map(&manhattan(point, &1))
    |> Enum.sum()
  end
end
