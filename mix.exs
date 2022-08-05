defmodule Hustle.MixProject do
  use Mix.Project

  def project do
    [
      app: :hustle,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp package do
    [
      description: "Server-side Web Push Notifications",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/christopherlai/hustle"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:hackney, "~> 1.18", optional: true},
      {:jason, "~> 1.3", optional: true},
      {:jose, "~> 1.11"}
    ]
  end
end
