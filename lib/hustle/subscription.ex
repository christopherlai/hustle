defmodule Hustle.Subscription do
  @moduledoc """
  The struct and functions in this module are utilized for the
  subscription data returned by the browser.
  """

  @type t :: %__MODULE__{
          url: String.t(),
          auth: binary(),
          p256dh: binary()
        }

  defstruct [:url, :auth, :p256dh]

  @doc """
  Returns a `Subscription` struct with the provide arguments.

  Both `auth` and `p256dh` strings are Base64 URL decode into `binary`
  before the struct is returned.
  """
  @spec new(url :: String.t(), auth :: String.t(), p256dh :: String.t()) :: t()
  def new(url, auth, p256dh) do
    {:ok, auth} = Base.url_decode64(auth, padding: false)
    {:ok, p256dh} = Base.url_decode64(p256dh, padding: false)

    fields = [
      url: url,
      auth: auth,
      p256dh: p256dh
    ]

    struct(__MODULE__, fields)
  end

  @doc """
  Returns the base URL for the given subscription.
  """
  @spec get_base_url(subscription :: t()) :: String.t()
  def get_base_url(%__MODULE__{url: url}) do
    uri = URI.parse(url)

    "#{uri.scheme}://#{uri.host}"
  end
end
