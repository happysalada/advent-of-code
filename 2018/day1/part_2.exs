File.read!("./input.txt")
|> String.split("\n", trim: true)
|> Enum.map(&String.to_integer/1)
|> Stream.cycle()
|> Stream.transform({0, %MapSet{} |> MapSet.put(0)}, fn
  digit, {sum, seen} ->
    sum = sum + digit
    acc = {sum, MapSet.put(seen, sum)}

    if MapSet.member?(seen, sum), do: {[sum], acc}, else: {[], acc}
end)
|> Enum.take(1)
|> IO.inspect()
