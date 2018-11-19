defmodule WFAlert.Nodes do
  require Logger

  @data_file Path.expand(
               "data/solNodes.json",
               Mix.Project.deps_paths()[:warframe_worldstate_data]
             )

  @external_resource @data_file

  @data @data_file
        |> File.read!()
        |> Poison.decode!()
        |> Map.new(fn {id, %{"value" => name}} -> {id, name} end)

  def name(id), do: Map.fetch!(@data, id)
  def node_and_planet(id), do: name(id) |> parse_name()

  @name_regex ~r{^([a-z ]+) \(([a-z ]+)\)$}i

  defp parse_name(name) do
    case Regex.run(@name_regex, name) do
      [_, name, planet] ->
        {name, planet}

      nil ->
        Logger.warn("Unexpected name: #{inspect(name)}")
        :unknown
    end
  end
end
