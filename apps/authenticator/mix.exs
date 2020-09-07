defmodule Authenticator.MixProject do
  use Mix.Project

  def project do
    [
      app: :authenticator,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      elixirc_paths: elixirc_paths(Mix.env()),
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # This makes sure your factory and any other modules in test/support are compiled
  # when in the test environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Umbrella
      {:resource_manager, in_umbrella: true},

      # Domain
      {:argon2_elixir, "~> 2.0"},
      {:joken, "~> 2.2"},
      {:jason, "~> 1.2"},

      # Tools
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: :test}
    ]
  end
end
