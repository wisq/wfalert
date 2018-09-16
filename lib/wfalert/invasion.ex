defmodule WFAlert.Invasion do
  alias WFAlert.{Invasion, Reward}

  @enforce_keys [:id, :rewards]
  defstruct(id: nil, rewards: [])

  def parse(blob) do
    count = Map.fetch!(blob, "Count")
    goal = Map.fetch!(blob, "Goal")

    if abs(count) >= goal do
      nil
    else
      reward1 = Map.fetch!(blob, "AttackerReward") |> Reward.parse()
      reward2 = Map.fetch!(blob, "DefenderReward") |> Reward.parse()

      %Invasion{id: id(blob), rewards: reward1 ++ reward2}
    end
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex
end
