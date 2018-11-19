defmodule WFAlert.Helpers.Utility do
  defmacro read_lines(file) do
    quote bind_quoted: [file: file] do
      Path.expand(file, Path.dirname(__ENV__.file))
      |> File.stream!()
      |> Enum.map(&:string.chomp/1)
      |> Enum.filter(&(&1 =~ ~r{^[^#]}))
    end
  end
end
