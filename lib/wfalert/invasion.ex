defmodule WFAlert.Invasion do
  alias WFAlert.Invasion

  @enforce_keys [:id, :rewards]
  defstruct(id: nil, rewards: [])

  def parse(blob) do
    count = Map.fetch!(blob, "Count")
    goal = Map.fetch!(blob, "Goal")

    if abs(count) >= goal do
      nil
    else
      reward1 = Map.fetch!(blob, "AttackerReward") |> parse_rewards()
      reward2 = Map.fetch!(blob, "DefenderReward") |> parse_rewards()

      %Invasion{id: id(blob), rewards: reward1 ++ reward2}
    end
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex

  defp parse_rewards(blob) do
    Enum.map(blob, fn {key, value} -> parse_rewards(key, value) end)
    |> List.flatten()
  end

  defp parse_rewards("credits", n) do
    {:credits, n}
  end

  defp parse_rewards("items", items) do
    Enum.map(items, fn item -> {:item, {1, item}} end)
  end

  defp parse_rewards("countedItems", items) do
    Enum.map(items, fn item ->
      count = Map.fetch!(item, "ItemCount")
      item = Map.fetch!(item, "ItemType")
      {:item, {count, item}}
    end)
  end
end
