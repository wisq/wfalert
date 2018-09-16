defmodule WFAlert.Items do
  @data_file Path.expand(
               "data/json/All.json",
               Mix.Project.deps_paths()[:warframe_items]
             )

  @external_resource @data_file

  @data_file
  |> File.read!()
  |> Poison.decode!()
  |> Enum.each(fn blob ->
    unique = Map.fetch!(blob, "uniqueName")
    name = Map.fetch!(blob, "name")

    def name(unquote(unique)), do: unquote(name)
  end)
end
