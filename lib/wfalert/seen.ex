defmodule WFAlert.Seen do
  alias WFAlert.Util

  def alerts, do: list("alerts")
  def invasions, do: list("invasions")
  def fissures, do: list("fissures")
  def cetus_cycle, do: time("cetus_cycle")

  def update_alerts(alerts), do: update_ids("alerts", alerts)
  def update_invasions(invasions), do: update_ids("invasions", invasions)
  def update_fissures(fissures), do: update_ids("fissures", fissures)
  def update_cetus_cycle(time), do: update_time("cetus_cycle", time)

  defp seen_file(type) do
    "seen/#{type}.txt"
    |> Path.expand(:code.priv_dir(:wfalert))
  end

  defp list(type) do
    file = seen_file(type)

    if File.regular?(file) do
      File.stream!(file)
      |> Enum.map(&:string.chomp/1)
    else
      []
    end
  end

  defp time(type) do
    case list(type) do
      [str] -> Util.string_to_datetime(str)
      [] -> DateTime.from_unix(0)
    end
  end

  defp update_ids(type, items) do
    update(
      type,
      items |> Enum.map(&"#{&1.id}")
    )

    items
  end

  defp update_time(type, time) do
    update(type, [Util.datetime_to_string(time)])
    time
  end

  defp update(type, lines) do
    seen_file(type)
    |> Util.mkparent()
    |> File.write(Enum.join(lines, "\n"))

    lines
  end
end
