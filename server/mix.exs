defmodule Chatme.Server.Mixfile do
  use Mix.Project

  def project do
    [app: :server,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Chatme.Server.Application, []}]
  end

  defp deps do
    []
  end

  defp escript do
    [main_module: Chatme.Server.Main,
     app: nil,
     path: "dist/server"]
  end
end
