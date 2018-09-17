defmodule WFAlert.Filter.Helpers do
  alias WFAlert.Filter

  def alert_filters(list) when is_list(list) do
    Application.put_env(:wfalert, :alert_filters, list)
  end

  def invasion_filters(list) when is_list(list) do
    Application.put_env(:wfalert, :invasion_filters, list)
  end

  @valid_actions [:show, :hide, :drop_item]

  def filter(action, fun) do
    unless Enum.member?(@valid_actions, action) do
      raise "Invalid action: #{inspect(action)}"
    end

    %Filter{action: action, condition: fun}
  end

  def filter_category(action, category) do
    filter(action, fn r -> r.category == category end)
  end

  def filter_name(action, name) do
    if Regex.regex?(name) do
      filter(action, fn r -> r.name =~ name end)
    else
      filter(action, fn r -> r.name == name end)
    end
  end

  def default(action) do
    filter(action, fn _ -> true end)
  end
end
