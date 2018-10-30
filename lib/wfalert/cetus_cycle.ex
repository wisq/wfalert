defmodule WFAlert.CetusCycle do
  require Logger
  alias WFAlert.{WorldState, Util, Seen}

  defmodule Period do
    alias Timex.Duration

    @enforce_keys [:type, :begins, :ends]
    defstruct(
      type: nil,
      begins: nil,
      ends: nil
    )

    # 100-minute days
    @cetus_day Duration.from_minutes(100)
    # 50-minute nights
    @cetus_night Duration.from_minutes(50)

    defp duration(:night), do: @cetus_night
    defp duration(:day), do: @cetus_day

    def next(%Period{type: :day, ends: time}), do: make(:night, starts: time)
    def next(%Period{type: :night, ends: time}), do: make(:day, starts: time)

    def previous(%Period{type: :day, begins: time}), do: make(:night, ends: time)
    def previous(%Period{type: :night, begins: time}), do: make(:day, ends: time)

    defp make(type, starts: time) do
      %Period{
        type: type,
        begins: time,
        ends: Timex.add(time, duration(type))
      }
    end

    defp make(type, ends: time) do
      %Period{
        type: type,
        begins: Timex.subtract(time, duration(type)),
        ends: time
      }
    end

    def night_ending_at(time) do
      make(:night, ends: time)
    end

    def current?(period, time \\ DateTime.utc_now()) do
      Timex.between?(time, period.begins, period.ends)
    end

    def find_period(period, time) do
      case compare(period, time) do
        :during -> period
        :before -> previous(period) |> find_period(time)
        :after -> next(period) |> find_period(time)
      end
    end

    def compare(period, time) do
      cond do
        current?(period, time) -> :during
        Timex.before?(time, period.begins) -> :before
        Timex.after?(time, period.ends) -> :after
      end
    end
  end

  def current(state \\ WorldState.fetch()) do
    sync_bounty_reset_time(state)
    |> Period.night_ending_at()
    |> Period.find_period(DateTime.utc_now())
  end

  def upcoming(state \\ WorldState.fetch()) do
    current(state)
    |> Stream.unfold(fn p -> {p, Period.next(p)} end)
  end

  def next_unseen_night(state \\ WorldState.fetch()) do
    cutoff = Seen.cetus_cycle()

    upcoming(state)
    |> Enum.find(fn p ->
      p.type == :night && Timex.after?(p.begins, cutoff)
    end)
  end

  def mark_night_seen(%Period{type: night, ends: time}) do
    Seen.update_cetus_cycle(time)
  end

  defp sync_bounty_reset_time(state) do
    case bounties(state) do
      nil ->
        Logger.warn("No Cetus bounties; using cached time.")

        get_from_cache()

      %{"Expiry" => time} ->
        Util.parse_time(time)
        |> save_to_cache()
    end
  end

  defp bounties(state) do
    state
    |> Map.fetch!("SyndicateMissions")
    |> Enum.find(fn m -> Map.fetch!(m, "Tag") == "CetusSyndicate" end)
  end

  defp cache_file() do
    "cache/cetus_bounty_time.txt"
    |> Path.expand(:code.priv_dir(:wfalert))
  end

  defp get_from_cache() do
    cache_file()
    |> File.read!()
    |> String.trim()
    |> Util.string_to_datetime()
  end

  defp save_to_cache(time) do
    cache_file()
    |> Util.mkparent()
    |> File.write!(Util.datetime_to_string(time))

    time
  end
end
