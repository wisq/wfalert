defmodule WFAlert.Notifier do
  require Logger
  alias WFAlert.{WorldState, Alert, Invasion, Pushover}

  def run() do
    state = WorldState.fetch()

    alert_lines =
      WorldState.new_alerts(state)
      |> Enum.filter(&Alert.match?/1)
      |> Enum.map(&Alert.one_line/1)

    invasion_lines =
      WorldState.new_invasions(state)
      |> Enum.filter(&Invasion.match?/1)
      |> Enum.map(&Invasion.one_line/1)

    notify(alert_lines, invasion_lines)
  end

  defp title(alerts, invasions) do
    [
      alert: Enum.count(alerts),
      invasion: Enum.count(invasions)
    ]
    |> Enum.reject(fn {_type, count} -> count == 0 end)
    |> Enum.map(fn {type, count} ->
      plural = unless count == 1, do: "s"
      "#{count} #{type}#{plural}"
    end)
    |> Enum.join(" + ")
  end

  defp notify([], []) do
    Logger.info("No unseen alerts or invasions match our filters.")
  end

  defp notify(alert_lines, invasion_lines) do
    title = title(alert_lines, invasion_lines)
    Pushover.send(title, alert_lines ++ invasion_lines)
    Logger.info("Alert sent: #{title}.")
  end
end
