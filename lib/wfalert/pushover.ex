defmodule WFAlert.Pushover do
  @pushover_uri "https://api.pushover.net/1/messages.json"

  defp pushover_token, do: get_env!(:pushover_api_token)
  defp pushover_user, do: get_env!(:pushover_user_key)

  defp get_env!(key) do
    case Application.get_env(:wfalert, key) do
      nil -> raise "#{inspect(key)} not set"
      any -> any
    end
  end

  def send(title, lines) do
    %{
      token: pushover_token(),
      user: pushover_user(),
      title: title,
      message: Enum.join(lines, "\n")
    }
    |> Poison.encode!()
    |> post_json()
  end

  defp post_json(body) do
    HTTPoison.post!(@pushover_uri, body, "Content-Type": "application/json")
  end
end
