defmodule WFAlert.Helpers.FissureFilter do
  alias WFAlert.FissureFilter
  import WFAlert.Helpers.Common

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

  def by_mission_type(action, type) do
    filter(action, fn f -> matches(f.mission_type, type) end)
  end

  def by_planet(action, name) do
    filter(action, fn f -> matches(f.planet, name) end)
  end

  def by_node(action, name) do
    filter(action, fn f -> matches(f.node, name) end)
  end

  def with_relic(%FissureFilter{} = ff, relic) do
    filter(ff.action, fn f ->
      ff.condition.(f) && matches(f.relic_type, relic)
    end)
  end

  def default(action) do
    filter(action, fn _ -> true end)
  end
end
