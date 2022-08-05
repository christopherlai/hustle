defmodule Hustle.Vapid do
  @moduledoc """
  Generates VAPID or Voluntary Application Server Identification
  public and private key pairs.
  """

  @doc """
  Generate a new VAPID (Voluntary Application Server Identification)
  """
  @spec generate :: {public :: binary(), private :: binary()}
  def generate do
    {public, private} = :crypto.generate_key(:ecdh, :prime256v1)

    {
      Base.url_encode64(public, padding: false),
      Base.url_encode64(private, padding: false)
    }
  end
end
