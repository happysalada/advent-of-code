defmodule Day5 do
  def part1(instructions) do
    instructions
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> maze_path(&instruction_changer_1/1)
    |> Enum.count()
  end

  def part2(instructions) do
    instructions
    |> String.splitter("\n", trim: true)
    |> Stream.map(&String.to_integer/1)
    |> maze_path(&instruction_changer_2/1)
    |> Enum.count()
  end

  def instruction_changer_1(instruction), do: instruction + 1

  def instruction_changer_2(instruction) when instruction >= 3, do: instruction - 1
  def instruction_changer_2(instruction), do: instruction + 1

  defp maze_path(instructions, instruction_changer) do
    Stream.unfold(
      new_maze(instructions),
      fn maze ->
        if maze.current_pos >= 0 and maze.current_pos < size(maze),
          do: {maze, move(maze, instruction_changer)},
          else: nil
      end
    )
  end

  defp size(maze), do: Map.size(maze.instructions)

  defp new_maze(instructions), do:
    %{
      current_pos: 0,
      instructions:
        instructions
        |> Stream.with_index()
        |> Stream.map(fn {instruction, index} -> {index, instruction} end)
        |> Map.new()
    }

  defp move(%{current_pos: current_pos, instructions: instructions}, instruction_changer) do
    current_instruction = Map.get(instructions, current_pos)
    %{
      current_pos: current_pos + current_instruction,
      instructions: Map.put(instructions, current_pos, instruction_changer.(current_instruction))
    }
  end
end
