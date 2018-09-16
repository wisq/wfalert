defmodule WFAlert.Items.Parser do
  def parse_file(file) do
    data =
      file
      |> File.read!()
      |> Poison.decode!()

    items = Map.new(data, &parse_item/1)

    components =
      Enum.map(data, &parse_components/1)
      |> List.flatten()
      |> Map.new()

    Map.merge(components, items)
  end

  defp parse_item(blob) do
    unique = Map.fetch!(blob, "uniqueName")
    name = Map.fetch!(blob, "name")

    {unique, name}
  end

  defp parse_components(blob) do
    name = Map.fetch!(blob, "name")

    Map.get(blob, "components", [])
    |> Enum.map(fn comp ->
      comp_unique = Map.fetch!(comp, "uniqueName")
      comp_name = [name, Map.fetch!(comp, "name")] |> Enum.join(" ")

      {comp_unique, comp_name}
    end)
  end
end
