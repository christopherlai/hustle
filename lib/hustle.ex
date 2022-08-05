defmodule Hustle do
  @moduledoc """
  Documentation for `Hustle`.
  """

  alias Hustle.Subscription
  alias Hustle.Vapid
  alias Hustle.HackneyClient

  @doc """
  Generates a VAPID public/private key pair.

  See `Hustle.Vapid` for more information.
  """
  @spec generate_vapid :: {public_key :: binary(), private_key :: binary()}
  defdelegate generate_vapid, to: Vapid, as: :generate

  def push(message, subscription, public_key, private_key, _opts \\ []) do
    {cipher, salt, server_public_key} =
      Hustle.Encryption.encrypt(message, subscription.p256dh, subscription.auth)

    jwt =
      subscription
      |> Subscription.get_base_url()
      |> Hustle.Jwt.generate(
        Base.url_decode64!(public_key, padding: false),
        Base.url_decode64!(private_key, padding: false)
      )

    headers = headers(jwt, salt, public_key, server_public_key)

    HackneyClient.request(subscription.url, headers, cipher)
  end

  defp headers(jwt, salt, public_key, server_public_key) do
    [
      {"TTL", "0"},
      {"Content-Encoding", "aesgcm"},
      {"Encryption", "salt=#{Base.url_encode64(salt, padding: false)}"},
      {"Authorization", "WebPush " <> jwt},
      {"Crypto-Key",
       "dh=#{Base.url_encode64(server_public_key, padding: false)}; p256ecdsa=#{public_key}"}
    ]
  end
end
