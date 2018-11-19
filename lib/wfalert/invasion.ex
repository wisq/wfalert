defmodule WFAlert.Invasion do
  alias WFAlert.{Invasion, Reward, RewardFilter}

  @enforce_keys [:id, :rewards]
  defstruct(
    id: nil,
    rewards: []
  )

  def parse(blob) do
    reward1 = Map.fetch!(blob, "AttackerReward") |> Reward.parse()
    reward2 = Map.fetch!(blob, "DefenderReward") |> Reward.parse()

    %Invasion{
      id: id(blob),
      rewards: reward1 ++ reward2
    }
  end

  def match?(invasion) do
    RewardFilter.match?(
      Application.get_env(:wfalert, :invasion_filters, []),
      invasion.rewards
    )
  end

  def one_line(invasion) do
    invasion.rewards
    |> Enum.map(&Reward.describe/1)
    |> Enum.sort()
    |> Enum.join(" + ")
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex
end
