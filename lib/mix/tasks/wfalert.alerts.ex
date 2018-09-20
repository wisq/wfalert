defmodule Mix.Tasks.Wfalert.Alerts do
  use Mix.Task
  alias WFAlert.{WorldState, Alert, Reward}

  @shortdoc "Show current alerts, and optionally see if they match"

  def run([]) do
    Mix.Task.run("app.start")

    WorldState.alerts()
    |> Enum.map(&show_alert/1)
    |> IO.puts()
  end

  def run([file]) do
    Mix.Task.run("app.start")

    Code.eval_file(file)

    WorldState.alerts()
    |> Enum.map(&show_alert/1)
    |> IO.puts()
  end

  def run(_) do
    Mix.raise("Usage: mix wfalert.alerts [config file]")
  end

  defp show_alert(alert) do
    [
      show_alert_base(alert),
      show_alert_match(alert),
      show_alert_lifetime(alert)
    ]
  end

  defp show_alert_base(alert) do
    [
      "\n--- Alert: #{alert.id} ---\n",
      alert.rewards
      |> Enum.sort_by(& &1.name)
      |> Enum.map(&show_reward/1)
    ]
  end

  defp show_alert_match(alert) do
    if Alert.match?(alert) do
      "- Matches alert filters.\n"
    else
      "- Does NOT match alert filters.\n"
    end
  end

  defp show_alert_lifetime(alert) do
    cond do
      !Alert.started?(alert) -> "- Alert has not started yet.\n"
      !Alert.expired?(alert) -> "- Alert has expired.\n"
      true -> ""
    end
  end

  defp show_reward(reward) do
    desc = Reward.describe(reward)

    [
      "- #{inspect(desc)} (#{inspect(reward.category)})\n",
      if is_atom(reward.id) do
        ""
      else
        "  id: #{inspect(reward.id)}\n"
      end
    ]
  end
end
