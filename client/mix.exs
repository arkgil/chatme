defmodule Chatme.Client.Mixfile do
  use Mix.Project

  def project do
    [app: :client,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: escript(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Chatme.Client.Application, []}]
  end

  defp deps do
    []
  end

  defp escript do
    [main_module: Chatme.Client.Main,
     app: nil,
     path: "dist/client"]
  end
end
