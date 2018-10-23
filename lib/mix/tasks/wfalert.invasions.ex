defmodule Mix.Tasks.Wfalert.Invasions do
  use Mix.Task
  alias WFAlert.{WorldState, Invasion, Reward}

  @shortdoc "Show current invasions, and optionally see if they match"

  def run([]) do
    Mix.Task.run("app.start")

    WorldState.invasions()
    |> Enum.map(&show_invasion/1)
    |> IO.puts()
  end

  def run([file]) do
    Mix.Task.run("app.start")

    Code.eval_file(file)

    WorldState.invasions()
    |> Enum.map(&show_invasion/1)
    |> IO.puts()
  end

  def run(_) do
    Mix.raise("Usage: mix wfalert.invasions [config file]")
  end

  defp show_invasion(inv) do
    [
      show_invasion_base(inv),
      show_invasion_match(inv)
    ]
  end

  defp show_invasion_base(inv) do
    [
      "\n--- Invasion: #{inv.id} ---\n",
      inv.rewards
      |> Enum.sort_by(& &1.name)
      |> Enum.map(&show_reward/1)
    ]
  end

  defp show_invasion_match(inv) do
    if Invasion.match?(inv) do
      "- Matches invasion filters.\n"
    else
      "- Does NOT match invasion filters.\n"
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
