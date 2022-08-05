defmodule Hustle.HTTPClient do
  @moduledoc """
  HTTP Client behaviour.

  The HTTP method for the `request` must be set to `POST`.
  """

  @callback request(url :: String.t(), headers :: keyword(), body :: binary()) ::
              :ok | {:error, reason :: any()}
end
