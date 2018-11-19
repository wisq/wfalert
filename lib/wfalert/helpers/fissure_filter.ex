defmodule WFAlert.Helpers.FissureFilter do
  alias WFAlert.FissureFilter

  def fissure_filters(list) when is_list(list) do
    Application.put_env(:wfalert, :fissure_filters, list)
  end

  @valid_actions [:show, :hide]

  def filter(action, fun) do
    unless Enum.member?(@valid_actions, action) do
      raise "Invalid action: #{inspect(action)}"
    end

    %FissureFilter{action: action, condition: fun}
  end

  def by_mission_type(action, types) when is_list(types) do
    filter(action, fn f -> f.mission_type in types end)
  end

  def by_mission_type(action, type) when is_atom(type) do
    by_mission_type(action, [type])
  end

  def default(action) do
    filter(action, fn _ -> true end)
  end
end
