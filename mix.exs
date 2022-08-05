defmodule AnonDown.MixProject do
  use Mix.Project

  def project do
    [
      app: :anon_down,
      version: "0.1.0",
      elixir: "~> 1.14-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :jason, :httpoison_retry, :floki],
      mod: {AnonDown.Application, []},
      applications: [:downstream]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:downstream, "~> 1.0.0"},
      {:jason, ">=0.0.0"},
      {:httpoison_retry, "~> 1.0.0"},
      {:floki, "~> 0.33.0"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
