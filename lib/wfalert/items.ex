defmodule WFAlert.Items do
  @data_file Path.expand(
               "dict/item.json",
               Mix.Project.deps_paths()[:pretty_bot]
             )

  @external_resource @data_file

  @data @data_file
        |> File.read!()
        |> Poison.decode!()
        |> Map.new()

  def name(id), do: Map.fetch(@data, id)
  def name!(id), do: Map.fetch!(@data, id)
end
