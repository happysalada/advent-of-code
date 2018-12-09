defmodule Day4 do
  def part1(passphrases) do
    passphrases
    |> String.splitter("\n", trim: true)
    |> Stream.map(&words/1)
    |> Stream.reject(&any_duplicate?/1)
    |> Enum.count()
  end

  def part2(passphrases) do
    passphrases
    |> String.splitter("\n", trim: true)
    |> Stream.map(&words/1)
    |> Stream.reject(&any_anagrams?/1)
    |> Enum.count()
  end

  defp words(passphrase) do
    String.splitter(passphrase, " ", trim: true)
  end

  defp any_duplicate?(enumerable) do
    enumerable
    |> Stream.transform(MapSet.new(), fn
      word, acc -> {[MapSet.member?(acc, word)], MapSet.put(acc, word)}
    end)
    |> Enum.any?()
  end

  defp any_anagrams?(words) do
    words
    |> Stream.map(fn word -> word |> String.codepoints() |> Enum.sort() end)
    |> any_duplicate?()
  end
end
