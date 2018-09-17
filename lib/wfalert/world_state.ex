defmodule WFAlert.WorldState do
  alias WFAlert.{Alert, Invasion, Seen}

  @uri "http://content.warframe.com/dynamic/worldState.php"

  def fetch do
    HTTPoison.get!(@uri)
    |> Map.fetch!(:body)
    |> Poison.decode!()
  end

  def alerts(state \\ fetch()) do
    state
    |> Map.fetch!("Alerts")
    |> Enum.map(&Alert.parse/1)
  end

  def new_alerts(state \\ fetch()) do
    seen = Seen.alerts()
    alerts = alerts(state)

    Seen.update_alerts(alerts)
    Enum.reject(alerts, &(&1.id in seen))
  end

  def new_invasions(state \\ fetch()) do
    seen = Seen.invasions()
    invs = invasions(state)

    Seen.update_invasions(invs)
    Enum.reject(invs, &(&1.id in seen))
  end

  def invasions(state \\ fetch()) do
    state
    |> Map.fetch!("Invasions")
    |> Enum.map(&Invasion.parse/1)
    |> Enum.reject(&is_nil/1)
  end
end
