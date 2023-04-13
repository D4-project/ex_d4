defmodule Exd4.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_d4,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      # Docs
      name: "D4 elixir client",
      source_url: "https://github.com/d4-project/ex_d4"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.9.4"},
      {:json, "~> 1.4.1"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Ex_d4 allows for communicating with d4-servers in elixir."
  end

  defp package() do
    [
      links: %{
        "GitHub" => "https://github.com/d4-project/ex_d4",
        "d4-project" => "https://d4-project.org"
      },
      homepage_url: "http://d4-project.org",
      licenses: ["MIT"],
      docs: [
        main: "D4 client",
        logo: "media/text12.png",
        extras: ["README.md"]
      ]
    ]
  end
end
