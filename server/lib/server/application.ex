defmodule Chatme.Server.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Chatme.Server.Listener, []),
      supervisor(Chatme.Server.ConnSup, []),
      supervisor(Chatme.Server.ConnRegistry, []),
    ]

    opts = [strategy: :one_for_one, name: Chatme.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
