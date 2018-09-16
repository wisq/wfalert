defmodule WFAlert.Alert do
  alias WFAlert.{Alert, Reward}

  @enforce_keys [:id, :expires, :rewards]
  defstruct(
    id: nil,
    expires: nil,
    rewards: []
  )

  def parse(blob) do
    IO.inspect(blob)
    expires = Map.fetch!(blob, "Expiry") |> parse_time()

    rewards =
      blob
      |> Map.fetch!("MissionInfo")
      |> Map.fetch!("missionReward")
      |> parse_rewards()

    %Alert{id: id(blob), expires: expires, rewards: rewards}
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex

  defp parse_time(%{"$date" => %{"$numberLong" => str}}) do
    String.to_integer(str)
  end

  defp parse_rewards(blob) do
    Enum.map(blob, fn {key, value} -> parse_rewards(key, value) end)
    |> List.flatten()
  end

  defp parse_rewards("credits", n) do
    Reward.credits(n)
  end

  defp parse_rewards("items", items) do
    Enum.map(items, fn id -> Reward.item(id) end)
  end

  defp parse_rewards("countedItems", items) do
    Enum.map(items, fn item ->
      count = Map.fetch!(item, "ItemCount")
      id = Map.fetch!(item, "ItemType")
      Reward.item(id, count)
    end)
  end
end
