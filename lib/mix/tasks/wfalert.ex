defmodule Mix.Tasks.Wfalert do
  use Mix.Task
  alias WFAlert.{WorldState, Alert, Invasion}

  @shortdoc "Load a config file and issue alerts"

  def run([file]) do
    {:ok, _started} = Application.ensure_all_started(:wfalert)

    Code.eval_file(file)

    state = WorldState.fetch()
    alerts = WorldState.alerts(state)
    invasions = WorldState.invasions(state)

    alerts
    |> Enum.filter(&Alert.match?/1)
    |> IO.inspect()

    invasions
    |> Enum.filter(&Invasion.match?/1)
    |> IO.inspect()
  end

  def run(_) do
    Mix.raise("Usage: mix wfalert <config file>")
  end
end
