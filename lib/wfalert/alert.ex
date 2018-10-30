defmodule WFAlert.Alert do
  alias WFAlert.{Alert, Reward, Filter}
  import WFAlert.Util, only: [parse_time: 1]

  @enforce_keys [:id, :expires, :rewards]
  defstruct(
    id: nil,
    starts: nil,
    expires: nil,
    rewards: []
  )

  def parse(blob) do
    starts = Map.fetch!(blob, "Activation") |> parse_time()
    expires = Map.fetch!(blob, "Expiry") |> parse_time()

    rewards =
      blob
      |> Map.fetch!("MissionInfo")
      |> Map.fetch!("missionReward")
      |> Reward.parse()

    %Alert{id: id(blob), starts: starts, expires: expires, rewards: rewards}
  end

  def match?(alert) do
    Filter.match?(
      Application.get_env(:wfalert, :alert_filters, []),
      alert.rewards
    )
  end

  def started?(alert) do
    DateTime.utc_now() |> DateTime.compare(alert.starts) == :gt
  end

  def expired?(alert) do
    DateTime.utc_now() |> DateTime.compare(alert.expires) == :lt
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
