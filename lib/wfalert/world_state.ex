defmodule WFAlert.WorldState do
  alias WFAlert.Alert
  alias WFAlert.Invasion

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

  def invasions(state \\ fetch()) do
    state
    |> Map.fetch!("Invasions")
    |> Enum.map(&Invasion.parse/1)
    |> Enum.reject(&is_nil/1)
  end
end
