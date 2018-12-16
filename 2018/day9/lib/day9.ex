defmodule Day9 do
  @moduledoc """
  Documentation for Day9.
  """

  defmodule Circle do
    defstruct circle: %{0 => {0, 0}},
              n_players: 1,
              last_player: 0,
              player_scores: %{},
              current_marble: 0,
              next_marble: 1

    def new(n_players) do
      {_last_player, player_scores} =
        List.duplicate(0, n_players)
        |> Enum.reduce({1, %{}}, fn init_score, {player, scores} ->
          {player + 1, Map.put(scores, player, init_score)}
        end)

      %Circle{n_players: n_players, player_scores: player_scores}
    end

    @spec next(%Circle{}) :: %Circle{}
    def next(
          %{
            circle: circle,
            current_marble: current_marble,
            n_players: n_players,
            next_marble: next_marble,
            last_player: last_player
          } = game
        )
        when rem(next_marble, 23) != 0 do
      {_one_counter_clockwise, one_clockwise} = Map.fetch!(circle, current_marble)
      {_current_marble, two_clockwise} = Map.fetch!(circle, one_clockwise)
      current_player = if(last_player == n_players, do: 1, else: last_player + 1)

      new_circle =
        circle
        |> Map.update!(one_clockwise, fn {counter_clockwise, _clockwise} ->
          {counter_clockwise, next_marble}
        end)
        |> Map.put(next_marble, {one_clockwise, two_clockwise})
        |> Map.update!(two_clockwise, fn {_counter_clockwise, clockwise} ->
          {next_marble, clockwise}
        end)

      %{
        game
        | circle: new_circle,
          current_marble: next_marble,
          next_marble: next_marble + 1,
          last_player: current_player
      }
    end

    def next(
          %{
            circle: circle,
            current_marble: current_marble,
            last_player: last_player,
            n_players: n_players,
            next_marble: next_marble,
            player_scores: player_scores
          } = game
        ) do
      removed_marble =
        current_marble
        |> Stream.iterate(fn marble ->
          {counter_clockwise, _clockwise} = Map.fetch!(circle, marble)
          counter_clockwise
        end)
        # drop the current marble
        |> Stream.drop(1)
        |> Enum.take(7)
        |> List.last()

      {one_counter_clockwise, one_clockwise} = Map.fetch!(circle, removed_marble)

      new_circle =
        circle
        |> Map.drop([removed_marble])
        |> Map.update!(one_counter_clockwise, fn {two_counter_clockwise, _removed_marble} ->
          {two_counter_clockwise, one_clockwise}
        end)
        |> Map.update!(one_clockwise, fn {_removed_marble, two_clockwise} ->
          {one_counter_clockwise, two_clockwise}
        end)

      current_player = if(last_player == n_players, do: 1, else: last_player + 1)

      player_scores =
        Map.update!(player_scores, current_player, &(&1 + removed_marble + next_marble))

      %{
        game
        | circle: new_circle,
          player_scores: player_scores,
          current_marble: one_clockwise,
          next_marble: next_marble + 1,
          last_player: current_player
      }
    end
  end

  @doc """
  provides a way to way to iterate on a game of marbles

  ## Examples

      # iex> Day9.Circle.new(10) |> Day9.traverser() |> Enum.take(4) |> List.last() |> elem(0)
      # 4
      # iex> Day9.Circle.new(10) |> Day9.traverser() |> Enum.take(23) |> List.last() |> elem(0)
      # 23
      # iex> {last_score, _circle} = Day9.Circle.new(10) |> Day9.traverser() |> Enum.take(25) |> List.last()
      # iex> last_score
      # 25

  """
  def traverser(%Circle{} = circle) do
    Stream.unfold(circle, fn circle ->
      circle = Day9.Circle.next(circle)
      {circle, circle}
    end)
  end

  def input() do
    [n_players, last_marble_score] =
      File.read!("./input.txt")
      |> String.trim()
      |> String.split([" players; last marble is worth ", " points"], trim: true)

    {String.to_integer(n_players), String.to_integer(last_marble_score)}
  end

  def play(%{current_marble: current_marble, player_scores: player_scores}, last_marble_score)
      when current_marble - 1 == last_marble_score do
    player_scores
    |> Map.values()
    |> Enum.max()
  end

  def play(circle, last_marble_score) do
    Day9.Circle.next(circle)
    |> play(last_marble_score)
  end

  @doc """
  computes the score of a marbles game

  ## Examples

      iex> Day9.score({9, 25})
      32
      iex> Day9.score({10, 1618})
      8317
      iex> Day9.score({17, 1104})
      2764
      iex> Day9.score({21, 6111})
      54718
      iex> Day9.score({30, 5807})
      37305
      iex> Day9.score({13, 7999})
      146373


  """
  def part1({n_players, last_marble_score}) do
    Circle.new(n_players)
    |> play(last_marble_score)
  end

  def part2({n_players, last_marble_score}) do
    Circle.new(n_players)
    |> play(last_marble_score * 100)
  end
end
