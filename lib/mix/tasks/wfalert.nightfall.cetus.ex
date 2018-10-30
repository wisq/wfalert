defmodule Mix.Tasks.Wfalert.Nightfall.Cetus do
  use Mix.Task
  require Logger
  alias WFAlert.{CetusCycle, Pushover}

  @shortdoc "Alert when nightfall is approaching"

  def run([mins_before, mins_remain]) do
    secs_before = String.to_integer(mins_before) * 60
    secs_remain = String.to_integer(mins_remain) * 60

    Mix.Task.run("app.start")

    night = CetusCycle.next_unseen_night()
    now = DateTime.utc_now()

    cond do
      CetusCycle.Period.current?(night) ->
        CetusCycle.mark_night_seen(night)

        if seconds_within?(now, night.ends, secs_remain) do
          into = interval(night.begins, now)
          Logger.info("Too far into night (#{into}).")
        else
          notify_current(night, now)
        end

      seconds_within?(now, night.begins, secs_before) ->
        CetusCycle.mark_night_seen(night)
        notify_upcoming(night, now)

      true ->
        until = interval(now, night.begins)
        Logger.info("Not close enough to nightfall yet (#{until}).")
    end
  end

  def run(_) do
    Mix.raise("Usage: mix wfalert.nightfall.cetus <minutes before> <minutes remaining>")
  end

  defp seconds_within?(a, b, max_delta) do
    Timex.diff(b, a, :seconds) <= max_delta
  end

  defp notify_current(night, now) do
    interval = interval(night.begins, now)

    Pushover.send("Cetus Nightfall", ["Night on Cetus began #{interval} ago."])
    Logger.info("Notification sent: Night began #{interval} ago.")
  end

  defp notify_upcoming(night, now) do
    interval = interval(now, night.begins)

    Pushover.send("Cetus Nightfall", ["Night on Cetus begins in #{interval}."])
    Logger.info("Notification sent: Night begins in #{interval}.")
  end

  defp interval(time1, time2) do
    secs = Timex.diff(time2, time1, :seconds)
    mins = div(secs, 60)

    "#{mins} minutes"
  end
end
