defmodule WFAlert.Reward do
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

  def describe(%Reward{category: :credits, name: name}), do: name
  def describe(%Reward{quantity: 1, name: name}), do: name
  def describe(%Reward{quantity: q, name: name}), do: "#{name} (#{q})"

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
      category: Items.category(id) || :unknown,
      quantity: quantity
    }
  end

  defp item_name(id) do
    case Items.name(id) do
      {:ok, name} -> name
      :error -> Path.basename(id)
    end
  end
end
