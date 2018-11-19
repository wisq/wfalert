defmodule Mix.Tasks.Wfalert.Fissures do
  use Mix.Task
  alias WFAlert.{WorldState, Fissure}

  @shortdoc "Show current fissures, and optionally see if they match"

  def run([]) do
    Mix.Task.run("app.start")

    WorldState.fissures()
    |> Enum.map(&show_fissure/1)
    |> IO.puts()
  end

  def run([file]) do
    Mix.Task.run("app.start")

    Code.eval_file(file)

    WorldState.fissures()
    |> Enum.map(&show_fissure/1)
    |> IO.puts()
  end

  def run(_) do
    Mix.raise("Usage: mix wfalert.fissures [config file]")
  end

  defp show_fissure(fissure) do
    [
      show_fissure_base(fissure),
      show_fissure_match(fissure),
      show_fissure_lifetime(fissure)
    ]
  end

  defp show_fissure_base(fissure) do
    [
      "\n--- Fissure: #{fissure.id} ---\n",
      "- #{Fissure.one_line(fissure)}\n"
    ]
  end

  defp show_fissure_match(fissure) do
    if Fissure.match?(fissure) do
      "- Matches fissure filters.\n"
    else
      "- Does NOT match fissure filters.\n"
    end
  end

  defp show_fissure_lifetime(fissure) do
    cond do
      !Fissure.started?(fissure) -> "- Fissure has not started yet.\n"
      !Fissure.expired?(fissure) -> "- Fissure has expired.\n"
      true -> ""
    end
  end
end
