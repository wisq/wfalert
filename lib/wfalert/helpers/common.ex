defmodule WFAlert.Helpers.Common do
  def matches(actual, expected) do
    cond do
      Regex.regex?(expected) -> actual =~ expected
      is_binary(expected) -> String.downcase(actual) == String.downcase(expected)
      is_atom(expected) -> actual == expected
      is_list(expected) -> Enum.any?(expected, &matches(actual, &1))
      true -> raise "Unknown match value: #{inspect(expected)}"
    end
  end
end
