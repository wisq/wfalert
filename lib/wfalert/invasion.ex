defmodule WFAlert.Invasion do
  alias WFAlert.{Invasion, Reward, Filter}

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
    Filter.match?(
      Application.get_env(:wfalert, :invasion_filters, []),
      invasion.rewards
    )
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex
end
