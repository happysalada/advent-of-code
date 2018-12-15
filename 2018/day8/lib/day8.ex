defmodule Day8 do
  @moduledoc """
  Documentation for Day8.
  """

  def input() do
    File.read!("./input.txt")
    |> String.trim()
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part1() do
    {root, []} =
      input()
      |> parse_node()

    root
    |> sum_metadata()
  end

  def part2() do
    {root, []} =
      input()
      |> parse_node()

    root
    |> metadata_value()
  end

  @doc """
  parse the puzzle input

  ## Examples

      iex> Day8.parse_node([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2])
      {%{
        metadata: [1, 1, 2],
        children: [
          %{
            children: [],
            metadata: [10, 11, 12]
          },
          %{
            children: [%{children: [], metadata: [99]}],
            metadata: [2]
          }
        ]
      }, []}

  """
  def parse_node([n_children, n_metadata | rest]) do
    {children, rest} = children(n_children, rest, [])
    {metadata, rest} = Enum.split(rest, n_metadata)

    {%{
       metadata: metadata,
       children: children
     }, rest}
  end

  @doc """
  computes the children of a list

  ## Examples

      iex> Day8.children(1, [1, 1, 0, 1, 99, 2], [])
      {[%{metadata: [2], children: [%{metadata: [99], children: []}]}], []}

      iex> Day8.children(2, [0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2], [])
      {[
        %{children: [], metadata: [10, 11, 12]},
        %{children: [%{children: [], metadata: [99]}], metadata: [2]}
      ], []}



  """
  def children(0, rest, acc), do: {Enum.reverse(acc), rest}

  def children(n_children, list, acc) do
    {node, rest} = parse_node(list)
    children(n_children - 1, rest, [node | acc])
  end

  @doc """
  computes the size of a child node

  ## Examples

      iex> Day8.sum_metadata(%{
      ...>  metadata: [1, 1, 2],
      ...>  children: [
      ...>    %{
      ...>      children: [],
      ...>      metadata: [10, 11, 12]
      ...>    },
      ...>    %{
      ...>      children: [%{children: [], metadata: [99]}],
      ...>      metadata: [2]
      ...>    }
      ...>  ]
      ...>})
      138

  """
  def sum_metadata(%{metadata: metadata, children: children}) do
    current_sum = metadata |> Enum.sum()
    children_sum = Enum.reduce(children, 0, &(sum_metadata(&1) + &2))
    current_sum + children_sum
  end

  @doc """
  computes the value of the child nodes from the meta data

  ## Examples

      iex> Day8.metadata_value(%{
      ...>  metadata: [1, 1, 2],
      ...>  children: [
      ...>    %{
      ...>      children: [],
      ...>      metadata: [10, 11, 12]
      ...>    },
      ...>    %{
      ...>      children: [%{children: [], metadata: [99]}],
      ...>      metadata: [2]
      ...>    }
      ...>  ]
      ...>})
      66

  """
  def metadata_value(%{metadata: metadata, children: []}), do: metadata |> Enum.sum()

  def metadata_value(%{metadata: metadata, children: children}) do
    metadata
    |> Enum.map(&metadata_value(Enum.at(children, &1 - 1, zero_node())))
    |> Enum.sum()
  end

  def zero_node(), do: %{metadata: [0], children: []}
end
