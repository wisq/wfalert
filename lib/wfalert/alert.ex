defmodule WFAlert.Alert do
  alias WFAlert.{Alert, Reward, Filter}

  @enforce_keys [:id, :expires, :rewards]
  defstruct(
    id: nil,
    expires: nil,
    rewards: []
  )

  def parse(blob) do
    expires = Map.fetch!(blob, "Expiry") |> parse_time()

    rewards =
      blob
      |> Map.fetch!("MissionInfo")
      |> Map.fetch!("missionReward")
      |> Reward.parse()

    %Alert{id: id(blob), expires: expires, rewards: rewards}
  end

  def match?(alert) do
    Filter.match?(
      Application.get_env(:wfalert, :alert_filters, []),
      alert.rewards
    )
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex

  defp parse_time(%{"$date" => %{"$numberLong" => str}}) do
    String.to_integer(str)
    |> DateTime.from_unix!(:milliseconds)
  end
end
