defmodule Hustle.Encryption do
  @moduledoc """
  This module encrypts the `payload` before transit to the Push Service.

  Implementation of IETF RFCs [rfc5869](https://datatracker.ietf.org/doc/html/rfc5869) and
  [rfc8188](https://datatracker.ietf.org/doc/html/rfc8188#section-2.2)

  """

  @type payload :: binary()
  @type p256dh :: binary()
  @type auth :: binary()
  @type padding_length :: non_neg_integer()
  @type cipher_text :: binary()
  @type salt :: binary()
  @type server_private_key :: binary()

  @salt_size 16

  @doc """
  Encrypts the `payload` with the given Client Public and Private keys
  """
  @spec encrypt(
          payload :: payload(),
          p256dh :: p256dh(),
          auth :: auth(),
          padding_length :: padding_length()
        ) :: {cipher_text(), salt(), server_private_key()}
  def encrypt(payload, p256dh, auth, padding_length \\ 0) do
    padded_payload = pad_payload(payload, padding_length)
    onetime_salt = :crypto.strong_rand_bytes(@salt_size)
    {server_public_key, server_private_key} = :crypto.generate_key(:ecdh, :prime256v1)

    shared_secret = :crypto.compute_key(:ecdh, p256dh, server_private_key, :prime256v1)

    prk = hkdf(auth, shared_secret, "Content-Encoding: auth" <> <<0>>, 32)

    cek_info = build_info("aesgcm", p256dh, server_public_key)
    cek = hkdf(onetime_salt, prk, cek_info, 16)

    nonce_info = build_info("nonce", p256dh, server_public_key)
    nonce = hkdf(onetime_salt, prk, nonce_info, 12)

    {cipher_text, cipher_tag} =
      :crypto.crypto_one_time_aead(:aes_128_gcm, cek, nonce, padded_payload, "", true)

    {cipher_text <> cipher_tag, onetime_salt, server_public_key}
  end

  # HMAC-based Key Derivation function (HKDF)
  # Initial keying material (IKM)
  # Pseudorandom Key (PRK)
  # Output Keying Material (OKM)
  # Content-Encryption Key (CEK)
  defp hkdf(_salt, _ikm, _cek_info, length) when length > 32, do: :error

  defp hkdf(salt, ikm, info, length) do
    salt
    |> hkdf_extract(ikm)
    |> hkdf_expand(info, length)
  end

  defp hkdf_extract(salt, ikm) do
    :hmac
    |> :crypto.mac_init(:sha256, salt)
    |> :crypto.mac_update(ikm)
    |> :crypto.mac_final()
  end

  defp hkdf_expand(prk, info, length) do
    :hmac
    |> :crypto.mac_init(:sha256, prk)
    |> :crypto.mac_update(info)
    |> :crypto.mac_update(<<1>>)
    |> :crypto.mac_final()
    |> :binary.part(0, length)
  end

  defp build_info(_type, client_public_key, _server_public_key)
       when byte_size(client_public_key) != 65,
       do: raise(ArgumentError, "invalid client public key length")

  defp build_info(_type, _client_public_key, server_public_key)
       when byte_size(server_public_key) != 65,
       do: raise(ArgumentError, "invalid server public key length")

  defp build_info(type, client_public_key, server_public_key) do
    Enum.join([
      "Content-Encoding: ",
      type,
      <<0>>,
      "P-256",
      <<0>>,
      <<byte_size(client_public_key)::unsigned-big-integer-size(16)>>,
      client_public_key,
      <<byte_size(server_public_key)::unsigned-big-integer-size(16)>>,
      server_public_key
    ])
  end

  defp pad_payload(payload, padding_length) do
    Enum.join([
      <<padding_length::unsigned-big-integer-size(16)>>,
      :binary.copy(<<0>>, padding_length),
      payload
    ])
  end
end
