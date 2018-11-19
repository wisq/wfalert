defmodule WFAlert.TimeUtils do
  def seconds_to_string(s) when abs(s) >= 3600 do
    h = div(s, 3600)
    m = abs(s) |> rem(3600) |> div(60)
    "#{h}h#{m}m"
  end

  def seconds_to_string(s) when abs(s) >= 60 do
    m = div(s, 60)
    "#{m}m"
  end
end
