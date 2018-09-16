defmodule WFAlert.Reward do
  alias WFAlert.{Reward, Items}

  @enforce_keys [:name, :category, :quantity]
  defstruct(
    name: nil,
    category: nil,
    quantity: 0
  )

  def credits(amount) do
    %Reward{
      name: "Credits",
      category: "Credits",
      quantity: amount
    }
  end

  def item(id, quantity \\ 1) do
    %Reward{
      name: item_name(id),
      category: "TODO",
      quantity: quantity
    }
  end

  defp item_name(id) do
    try do
      Items.name(id)
    rescue
      FunctionClauseError -> Path.basename(id)
    end
  end
end
