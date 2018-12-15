defmodule Day7 do
  @moduledoc """
  Documentation for Day7.
  """

  def input() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
  end

  def part1() do
    input()
    |> parse_input()
    |> process()
  end

  def part2() do
    input()
    |> parse_input()
    |> process_parallel(60, 5)
  end

  @doc """
  parse the input and returns a map between a step and the ones that it depends on

  ## Examples

      iex> Day7.parse_input(["Step G must be finished before step T can begin."])
      %{"T" => ["G"]}
      iex> Day7.parse_input([
      ...> "Step C must be finished before step A can begin.",
      ...> "Step C must be finished before step F can begin.",
      ...> "Step A must be finished before step B can begin.",
      ...> "Step A must be finished before step D can begin.",
      ...> "Step B must be finished before step E can begin.",
      ...> "Step D must be finished before step E can begin.",
      ...> "Step F must be finished before step E can begin."])
      %{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]}

  """
  def parse_input(input_lines) do
    input_lines
    |> Enum.map(fn line ->
      [first_step, dependent] =
        String.split(line, ["Step ", " must be finished before step ", " can begin."], trim: true)

      {first_step, dependent}
    end)
    |> Enum.reduce(%{}, fn {first_step, dependent}, acc ->
      Map.update(acc, dependent, [first_step], fn prerequisites ->
        [first_step | prerequisites]
      end)
    end)
  end

  @doc """
  process a dependence tree

  ## Examples

      iex> Day7.process(%{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]})
      "CABDFE"

  """
  def process(tree) do
    process(tree, [], to_process(tree))
  end

  defp process(_tree, processed, []), do: processed |> Enum.reverse() |> Enum.join("")

  defp process(tree, processed, to_process) do
    steps_with_dependents = Map.keys(tree)

    next =
      to_process
      |> Enum.find(fn step -> not (step in steps_with_dependents) end)

    tree = remove(tree, next)
    to_process = Enum.filter(to_process, &(&1 != next))
    process(tree, [next | processed], to_process)
  end

  @doc """
  process jobs in parallel, with a number of worker and a base duration for each job

  ## Examples

      iex> Day7.process_parallel(%{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]}, 0, 2)
      15

  """
  def process_parallel(tree, base_duration, workers) do
    process_parallel(tree, 0, to_process(tree), %{}, base_duration, workers)
  end

  defp process_parallel(_tree, time, [], in_process, _base_duration, _workers)
       when in_process == %{},
       do: time

  defp process_parallel(tree, time, to_process, in_process, base_duration, workers) do
    steps_with_dependents = Map.keys(tree)

    case next_to_process(to_process, steps_with_dependents, workers) do
      [] ->
        {tree, in_process, workers} = increment_time(tree, in_process, workers)

        process_parallel(
          tree,
          time + 1,
          to_process,
          in_process,
          base_duration,
          workers
        )

      nexts ->
        in_process = in_process(nexts, in_process, base_duration)
        to_process = Enum.filter(to_process, &(not (&1 in nexts)))

        process_parallel(
          tree,
          time,
          to_process,
          in_process,
          base_duration,
          workers - length(nexts)
        )
    end
  end

  @doc """
  finds out the next steps to process

  ## Examples

      iex> Day7.next_to_process(["A", "B", "C", "D", "E", "F"], ["A", "B", "D", "E", "F"], 2)
      ["C"]

  """
  def next_to_process(to_process, steps_with_dependents, workers) do
    to_process
    |> Enum.filter(fn step -> not (step in steps_with_dependents) end)
    |> Enum.take(workers)
  end

  @doc """
  generates the map of jobs in process

  ## Examples

      iex> Day7.in_process(["C"], %{}, 0)
      %{"C" => 3}

  """
  def in_process(nexts, in_process, base_duration) do
    nexts
    |> Enum.reduce(in_process, fn <<step_codepoint>> = step, acc ->
      Map.put(acc, step, step_codepoint - 64 + base_duration)
    end)
  end

  @doc """
  increments time for the steps in process

  ## Examples

      iex> Day7.increment_time(%{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]}, %{"C" => 3}, 1)
      {%{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]}, %{"C" => 2}, 1}

  """
  def increment_time(tree, in_process, workers) do
    finished =
      in_process
      |> Enum.filter(fn
        {_step, 1} -> true
        _ -> false
      end)
      |> Enum.map(&elem(&1, 0))

    in_process =
      in_process
      |> Enum.filter(fn {step, _} -> not (step in finished) end)
      |> Enum.map(fn {step, duration} -> {step, duration - 1} end)
      |> Enum.into(%{})

    case finished do
      [] ->
        {tree, in_process, workers}

      finished ->
        tree = remove(tree, finished)
        {tree, in_process, workers + length(finished)}
    end
  end

  @doc """
  removes a processed step from a dependency tree

  ## Examples

      iex> Day7.remove(%{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]}, "C")
      %{"B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"]}

  """
  def remove(tree, steps_to_remove) when is_list(steps_to_remove) do
    tree
    |> Enum.reduce(%{}, fn {step, depends_on}, acc ->
      case depends_on |> Enum.filter(&(not (&1 in steps_to_remove))) do
        [] ->
          acc

        depends_on ->
          Map.put(acc, step, depends_on)
      end
    end)
  end

  def remove(tree, step_to_remove) do
    tree
    |> Enum.reduce(%{}, fn {step, depends_on}, acc ->
      case depends_on do
        [^step_to_remove] ->
          acc

        depends_on ->
          Map.put(acc, step, Enum.filter(depends_on, &(&1 != step_to_remove)))
      end
    end)
  end

  @doc """
  gives the list of all the stesp to process from a dependency tree, sorted in alphabetical order.

  ## Examples

      iex> Day7.to_process(%{"A" => ["C"], "B" => ["A"], "D" => ["A"], "E" => ["F", "D", "B"], "F" => ["C"]})
      ["A", "B", "C", "D", "E", "F"]

  """
  def to_process(tree) do
    steps_with_dependents = Map.keys(tree) |> MapSet.new()
    dependents = Map.values(tree) |> Enum.flat_map(& &1) |> MapSet.new()

    MapSet.union(steps_with_dependents, dependents)
    |> MapSet.to_list()
    |> Enum.sort()
  end
end
