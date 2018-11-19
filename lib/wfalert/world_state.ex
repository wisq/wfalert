defmodule WFAlert.WorldState do
  require Logger
  alias WFAlert.{Alert, Invasion, Fissure, Seen}
  alias WFAlert.WorldState.Cache

  @uri "http://content.warframe.com/dynamic/worldState.php"

  def fetch(cached \\ true)

  def fetch(true) do
    Cache.fetch() || fetch(false)
  end

  def fetch(false) do
    Logger.info("Retrieving world state ...")

    HTTPoison.get!(@uri)
    |> Map.fetch!(:body)
    |> Poison.decode!()
    |> Cache.store()
  end

  def alerts(state \\ fetch()) do
    state
    |> Map.fetch!("Alerts")
    |> Enum.map(&Alert.parse/1)
    |> log("alert")
  end

  def invasions(state \\ fetch()) do
    state
    |> Map.fetch!("Invasions")
    |> Enum.map(&Invasion.parse/1)
    |> Enum.reject(&is_nil/1)
    |> log("invasion")
  end

  def fissures(state \\ fetch()) do
    state
    |> Map.fetch!("ActiveMissions")
    |> Enum.map(&Fissure.parse/1)
    |> Fissure.sort()
    |> log("fissure")
  end

  def new_alerts(state \\ fetch()) do
    seen = Seen.alerts()

    alerts(state)
    |> Seen.update_alerts()
    |> Enum.reject(&(&1.id in seen))
    |> log("unseen alert")
  end

  def new_invasions(state \\ fetch()) do
    seen = Seen.invasions()

    invasions(state)
    |> Seen.update_invasions()
    |> Enum.reject(&(&1.id in seen))
    |> log("unseen invasion")
  end

  def new_fissures(state \\ fetch()) do
    seen = Seen.fissures()

    fissures(state)
    |> Seen.update_fissures()
    |> Enum.reject(&(&1.id in seen))
    |> log("unseen fissure")
  end

  defp log(items, type) do
    count = Enum.count(items)
    plural = unless count == 1, do: "s"
    Logger.info("Got #{count} #{type}#{plural}.")
    items
  end
end
