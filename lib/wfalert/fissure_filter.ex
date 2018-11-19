defmodule WFAlert.FissureFilter do
  @enforce_keys [:action, :condition]
  defstruct(
    action: nil,
    condition: nil
  )

  defmodule State do
    @enforce_keys [:rewards]
    defstruct(
      rewards: nil,
      action: nil
    )
  end

  # No filters, so it passes.
  def match?([], _rewards), do: true

  def match?(filters, fissure) do
    matching = Enum.find(filters, fn f -> f.condition.(fissure) end)

    case matching.action do
      :show -> true
      :hide -> false
    end
  end
end
