defmodule WFAlert.Filter do
  @enforce_keys [:action, :condition]
  defstruct(
    action: nil,
    condition: nil
  )
end
