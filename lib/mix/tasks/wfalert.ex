defmodule Mix.Tasks.Wfalert do
  use Mix.Task
  alias WFAlert.Notifier

  @shortdoc "Load a config file and issue alerts"

  def run([file]) do
    Mix.Task.run("app.start")

    Code.eval_file(file)
    Notifier.run()
  end

  def run(_) do
    Mix.raise("Usage: mix wfalert <config file>")
  end
end
