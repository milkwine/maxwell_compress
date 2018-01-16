defmodule MaxwellCompress.Mixfile do
  use Mix.Project

  def project do
    [
      app: :maxwell_compress,
      version: "0.0.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
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
    [ {:maxwell, "~> 2.2"} ]
  end
end
