defmodule WFAlert do
  use Application

  def start(_type, _args) do
    children = [
      {WFAlert.WorldState.Cache, nil}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
