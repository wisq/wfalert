defmodule WFAlert.Util do
  def parse_time(%{"$date" => %{"$numberLong" => str}}) do
    string_to_datetime(str)
  end

  def string_to_datetime(str) do
    str
    |> String.to_integer()
    |> DateTime.from_unix!(:milliseconds)
  end

  def datetime_to_string(time) do
    time
    |> DateTime.to_unix(:milliseconds)
    |> Integer.to_string()
  end

  def mkparent(file) do
    Path.dirname(file)
    |> File.mkdir_p!()

    file
  end
end
