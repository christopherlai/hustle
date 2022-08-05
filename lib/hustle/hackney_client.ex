defmodule Hustle.HackneyClient do
  @moduledoc """
  `Hackney` HTTP Client behaviour.
  """

  @behaviour Hustle.HTTPClient

  @impl true
  def request(url, headers, body) do
    case :hackney.request(:post, url, headers, body, with_body: true) do
      {:ok, 201, _headers, _body} -> :ok
      {:ok, _status_code, _headers, body} -> {:error, body}
      {:error, reason} -> {:error, reason}
    end
  end
end
