defmodule WFAlert.WorldState.Cache do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def fetch(max_age \\ 60_000) do
    {time, data} = GenServer.call(__MODULE__, :fetch)
    delta = DateTime.utc_now() |> DateTime.diff(time, :millisecond)

    if delta <= max_age do
      data
    else
      nil
    end
  end

  def store(data) do
    time = DateTime.utc_now()
    GenServer.cast(__MODULE__, {:store, time, data})
    data
  end

  @impl true
  def init(_) do
    epoch = DateTime.from_unix!(0)
    {:ok, {epoch, nil}}
  end

  @impl true
  def handle_call(:fetch, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:store, time, data}, _state) do
    {:noreply, {time, data}}
  end
end
