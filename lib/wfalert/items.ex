defmodule WFAlert.Items do
  require Logger

  @data_file Path.expand(
               "data/languages.json",
               Mix.Project.deps_paths()[:warframe_worldstate_data]
             )

  @external_resource @data_file

  @data @data_file
        |> File.read!()
        |> Poison.decode!()
        |> Map.new(fn {id, %{"value" => name}} -> {id, name} end)

  def name(id), do: Map.fetch(@data, String.downcase(id))
  def name!(id), do: Map.fetch!(@data, String.downcase(id))

  def category("/Lotus/Types/Recipes/Weapons/WeaponParts/" <> _), do: :weapon_part
  def category("/Lotus/Types/Items/Research/" <> _), do: :crafting_part
  def category("/Lotus/Types/Items/MiscItems/" <> _), do: :resource
  def category("/Lotus/StoreItems/Upgrades/Mods/FusionBundles/" <> _), do: :endo
  def category("/Lotus/StoreItems/Upgrades/Mods/Aura/" <> _), do: :aura_mod
  def category("/Lotus/StoreItems/Upgrades/Mods/" <> _), do: :mod

  def category(id) do
    cond do
      id =~ ~r{^/Lotus/Types/Recipes/Weapons/.*Blueprint$} ->
        :weapon_blueprint

      id =~ ~r{^/Lotus/StoreItems/Types/Recipes/Helmets/.*Blueprint$} ->
        :helmet_blueprint

      id =~ ~r{^/Lotus/StoreItems/Types/Recipes/WarframeRecipes/.*Blueprint$} ->
        :warframe_blueprint

      id =~ ~r{^/Lotus/StoreItems/Types/Recipes/.*Blueprint$} ->
        :blueprint

      true ->
        Logger.warn("Unknown category: #{inspect(id)}")
        nil
    end
  end
end
