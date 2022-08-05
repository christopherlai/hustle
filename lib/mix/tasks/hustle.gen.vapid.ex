defmodule Mix.Tasks.Hustle.Gen.Vapid do
  use Mix.Task

  def run(_args) do
    {public, private} = Hustle.Vapid.generate()

    Mix.Shell.IO.info("""
    Public Key: #{public}
    Private Key: #{private}
    """)
  end
end
