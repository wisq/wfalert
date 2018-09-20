defmodule WFAlert.Filter.Helpers do
  alias WFAlert.Filter

  defmacro __using__(_opts) do
    quote do
      import WFAlert.Filter.Helpers
    end
  end

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

  def by_category(action, category) do
    filter(action, fn r -> matches(r.category, category) end)
  end

  def by_name(action, name) do
    filter(action, fn r -> matches(r.name, name) end)
  end

  def by_id(action, id) do
    filter(action, fn r -> matches(r.id, id) end)
  end

  def by_category_and_name(action, category, name) do
    filter(action, fn r ->
      matches(r.category, category) && matches(r.name, name)
    end)
  end

  def default(action) do
    filter(action, fn _ -> true end)
  end

  defmacro read_lines(file) do
    quote bind_quoted: [file: file] do
      Path.expand(file, Path.dirname(__ENV__.file))
      |> File.stream!()
      |> Enum.map(&:string.chomp/1)
      |> Enum.filter(&(&1 =~ ~r{^[^#]}))
    end
  end

  defp matches(actual, expected) do
    cond do
      Regex.regex?(expected) -> actual =~ expected
      is_binary(expected) -> String.downcase(actual) == String.downcase(expected)
      is_atom(expected) -> actual == expected
      is_list(expected) -> Enum.any?(expected, &matches(actual, &1))
      true -> raise "Unknown match value: #{inspect(expected)}"
    end
  end
end
