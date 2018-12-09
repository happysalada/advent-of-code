File.read!("./input.txt")
|> String.split("\n", trim: true)
|> Enum.map(fn label ->
  label
  |> String.split("", trim: true)
  |> Enum.reduce(%{}, fn letter, acc ->
    Map.update(acc, letter, 1, &(&1 + 1))
  end)
  |> Map.values()
  |> MapSet.new()
end)
|> Enum.reduce({0, 0}, fn count_set, {duplicates, triples} ->
  duplicates =
    if MapSet.member?(count_set, 2) do
      duplicates + 1
    else
      duplicates
    end

  triples =
    if MapSet.member?(count_set, 3) do
      triples + 1
    else
      triples
    end

  {duplicates, triples}
end)
|> (&(elem(&1, 0) * elem(&1, 1))).()
|> IO.inspect()
