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

  def one_line(alert) do
    rewards =
      alert.rewards
      |> Enum.map(&Reward.describe/1)
      |> Enum.sort()
      |> Enum.join(" + ")

    expiry = time_to_expire(alert) |> seconds_to_string()
    "#{rewards} – #{expiry}"
  end

  defp id(%{"_id" => %{"$oid" => hex}}), do: hex

  defp parse_time(%{"$date" => %{"$numberLong" => str}}) do
    String.to_integer(str)
    |> DateTime.from_unix!(:milliseconds)
  end

  defp time_to_expire(alert) do
    DateTime.diff(alert.expires, DateTime.utc_now())
  end

  defp seconds_to_string(s) when abs(s) >= 3600 do
    h = div(s, 3600)
    m = abs(s) |> rem(3600) |> div(60)
    "#{h}h#{m}m"
  end

  defp seconds_to_string(s) when abs(s) >= 60 do
    m = div(s, 60)
    "#{m}m"
  end
end
