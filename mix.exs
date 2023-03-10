defmodule Exd4.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_d4,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "D4 elixir client",
      organization: "d4project",
      source_url: "https://github.com/d4-project/ex_d4",
      homepage_url: "http://d4-project.org",
      licence: "MIT",
      docs: [
        main: "D4 client",
        logo: "media/text12.png",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.9.4"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
