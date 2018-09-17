defmodule WFAlert.Seen do
  def alerts, do: list("alerts")
  def invasions, do: list("invasions")

  def update_alerts(alerts), do: update("alerts", alerts)
  def update_invasions(invasions), do: update("invasions", invasions)

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

  defp update(type, items) do
    ids =
      items
      |> Enum.map(&"#{&1.id}\n")

    seen_file(type)
    |> mkparent()
    |> File.write(ids)
  end

  defp mkparent(file) do
    Path.dirname(file)
    |> File.mkdir_p!()

    file
  end
end
