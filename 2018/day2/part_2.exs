defmodule InventoryManagement do
  def similar?(box_id_1, box_id_2) do
    box_id_1_letters = box_id_1 |> String.split("", trim: true)
    box_id_2_letters = box_id_2 |> String.split("", trim: true)

    Enum.zip(box_id_1_letters, box_id_2_letters)
    |> Enum.filter(fn {first_letter, second_letter} -> first_letter != second_letter end)
    |> Enum.count()
    |> (&(&1 < 3)).()
  end

  def similarity(box_id_1, box_id_2) do
    box_id_1_letters = box_id_1 |> String.split("", trim: true)
    box_id_2_letters = box_id_2 |> String.split("", trim: true)

    Enum.zip(box_id_1_letters, box_id_2_letters)
    |> Enum.filter(fn {first_letter, second_letter} -> first_letter == second_letter end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.join("")
  end

  def run() do
    File.read!("./input.txt")
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn
      _box_id, matched_tuple when is_tuple(matched_tuple) ->
        matched_tuple

      box_id, box_ids when is_list(box_ids) ->
        case Enum.find(box_ids, fn past_id -> similar?(past_id, box_id) end) do
          nil -> [box_id | box_ids]
          similar_id -> {box_id, similar_id}
        end
    end)
    |> (&similarity(elem(&1, 0), elem(&1, 1))).()
    |> IO.inspect()
  end
end

InventoryManagement.run()
