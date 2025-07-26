defmodule SnatchEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :snatch_ex,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SnatchEx.Application, []}
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:finch, "~> 0.19"},
      {:floki, "~> 0.34"},
      {:jason, "~> 1.4"},
      {:lcov_ex, "~> 0.3", only: [:dev, :test], runtime: false},
      {:mimic, "~> 2.0", only: :test},
      {:multipart, "~> 0.4"},
      {:pdf, "~> 0.7"},
      {:plug, "~> 1.16"},
      {:plug_cowboy, "~> 2.7"},
      {:remote_ip, "~> 1.2"},
      {:telegex, "~> 1.8"}
    ]
  end
end
