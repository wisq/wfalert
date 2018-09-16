defmodule WFAlert.Filter.Helpers do
  alias WFAlert.Filter

  def filter(action, fun) do
    %Filter{action: action, condition: fun}
  end

  def default(action) do
    filter(action, fn _ -> true end)
  end
end
