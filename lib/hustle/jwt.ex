defmodule Hustle.Jwt do
  @default_expiration 60 * 60 * 12
  def generate(audience, public_key, private_key, expires_in \\ @default_expiration) do
    expiration =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.+(expires_in)

    payload =
      %{
        aud: audience,
        exp: expiration,
        sub: "mailto: someone@example.com"
      }
      |> JOSE.JWT.from_map()

    jwk =
      {:ECPrivateKey, 1, private_key, {:namedCurve, {1, 2, 840, 10045, 3, 1, 7}}, public_key, nil}
      |> JOSE.JWK.from_key()

    {_, jwt} = JOSE.JWS.compact(JOSE.JWT.sign(jwk, %{"alg" => "ES256"}, payload))

    jwt
  end
end
