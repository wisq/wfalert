defmodule WFAlert.Items do
  @data_file Path.expand(
               "data/json/All.json",
               Mix.Project.deps_paths()[:warframe_items]
             )

  @external_resource @data_file

  @data_file
  |> WFAlert.Items.Parser.parse_file()
  |> Enum.each(fn {unique, name} ->
    def name(unquote(unique)), do: unquote(name)
  end)
end
