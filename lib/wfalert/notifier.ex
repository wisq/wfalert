defmodule WFAlert.Notifier do
  require Logger
  alias WFAlert.{WorldState, Alert, Invasion, Fissure, Pushover}

  def run() do
    state = WorldState.fetch()

    notify(
      alert:
        WorldState.new_alerts(state)
        |> Enum.filter(&Alert.match?/1)
        |> Enum.map(&Alert.one_line/1),
      invasion:
        WorldState.new_invasions(state)
        |> Enum.filter(&Invasion.match?/1)
        |> Enum.map(&Invasion.one_line/1),
      fissure:
        WorldState.new_fissures(state)
        |> Enum.filter(&Fissure.match?/1)
        |> Enum.map(&Fissure.one_line/1)
    )
  end

  defp title(items) do
    counts =
      items
      |> Enum.map(fn {type, list} -> {type, Enum.count(list)} end)
      |> Enum.reject(fn {_type, count} -> count == 0 end)

    case counts do
      [] ->
        nil

      cs ->
        Enum.map(cs, fn {type, count} ->
          plural = unless count == 1, do: "s"
          "#{count} #{type}#{plural}"
        end)
        |> Enum.join(" + ")
    end
  end

  defp notify(items) do
    case title(items) do
      nil ->
        Logger.info("No unseen items match our filters.")

      title ->
        Pushover.send(title, Keyword.values(items) |> List.flatten())
        Logger.info("Alert sent: #{title}.")
    end
  end
end
