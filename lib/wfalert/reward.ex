defmodule WFAlert.Reward do
  require Logger
  alias WFAlert.{Reward, Items}

  @enforce_keys [:id, :name, :category, :quantity]
  defstruct(
    id: nil,
    name: nil,
    category: nil,
    quantity: 0
  )

  def parse(blob) do
    Enum.map(blob, fn {key, value} -> parse_reward(key, value) end)
    |> List.flatten()
  end

  defp parse_reward("credits", amount) do
    %Reward{
      id: :credits,
      name: "#{amount}cr",
      category: :credits,
      quantity: amount
    }
  end

  defp parse_reward("items", items) do
    Enum.map(items, fn id -> item(id) end)
  end

  defp parse_reward("countedItems", items) do
    Enum.map(items, fn item ->
      count = Map.fetch!(item, "ItemCount")
      id = Map.fetch!(item, "ItemType")
      item(id, count)
    end)
  end

  defp item(id, quantity \\ 1) do
    %Reward{
      id: id,
      name: item_name(id),
      category: category(id),
      quantity: quantity
    }
  end

  defp item_name(id) do
    case Items.name(id) do
      {:ok, name} -> name
      :error -> Path.basename(id)
    end
  end

  defp category("/Lotus/Types/Recipes/Weapons/WeaponParts/" <> _), do: :weapon_part
  defp category("/Lotus/Types/Items/Research/" <> _), do: :crafting_part
  defp category("/Lotus/Types/Items/MiscItems/" <> _), do: :resource
  defp category("/Lotus/StoreItems/Upgrades/Mods/FusionBundles/" <> _), do: :endo

  defp category(id) do
    cond do
      id =~ ~r{^/Lotus/Types/Recipes/Weapons/.*Blueprint$} ->
        :weapon_blueprint

      true ->
        Logger.error("Unknown reward: #{inspect(id)}")
        :unknown
    end
  end
end
