defmodule InverseCaptcha do
  @spec sum_match_next(String.t) :: integer
  def sum_match_next(<<_::binary-size(0)>>), do: 0
  def sum_match_next(<<_::binary-size(1)>>), do: 0
  def sum_match_next(values) do
    int_list =
      String.split(values, "", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()

    Enum.reduce(int_list, 0, fn
      {int, index}, acc ->
        Enum.at(int_list, rem(index + 1, length(int_list)))
        |> case do
          {^int, _} -> acc + int
          _ -> acc
        end
    end)
  end

  def sum_match_index(values) do
    int_list =
      String.split(values, "", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()

    size = length(int_list)
    Enum.reduce(int_list, 0, fn
      {int, index}, acc ->
        Enum.at(int_list, rem(index + div(size,2), size))
        |> case do
          {^int, _} -> acc + int
          _ -> acc
        end
    end)
  end
end
