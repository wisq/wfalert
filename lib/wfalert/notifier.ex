defmodule WFAlert.Notifier do
  require Logger
  alias WFAlert.{WorldState, Alert, Invasion}

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
    pushover(title, alert_lines ++ invasion_lines)
    Logger.info("Alert sent: #{title}.")
  end

  @pushover_uri "https://api.pushover.net/1/messages.json"

  defp pushover_token, do: get_env!(:pushover_api_token)
  defp pushover_user, do: get_env!(:pushover_user_key)

  defp get_env!(key) do
    case Application.get_env(:wfalert, key) do
      nil -> raise "#{inspect(key)} not set"
      any -> any
    end
  end

  defp pushover(title, lines) do
    %{
      token: pushover_token(),
      user: pushover_user(),
      title: title,
      message: Enum.join(lines, "\n")
    }
    |> Poison.encode!()
    |> post_json()
  end

  defp post_json(body) do
    HTTPoison.post!(@pushover_uri, body, "Content-Type": "application/json")
  end
end
