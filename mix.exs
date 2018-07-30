defmodule MaxwellCompress.Mixfile do
  use Mix.Project

  def project do
    [
      app: :maxwell_compress,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      package: %{
        licenses: ["MIT"],
        maintainers: ["milkwine"],
        links: %{"GitHub" => "https://github.com/milkwine/maxwell_compress"}
      },
      deps: deps(),
      description: description(),
    ]
  end

  defp description do
    """
    Maxwell middleware to do `HTTP compression`. Now support `gzip` method.
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:maxwell, ">= 2.2.0"},
      {:poison, "~> 2.1 or ~> 3.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: [:dev]},
    ]
  end
end
