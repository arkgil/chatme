defmodule Chatme.Server.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    config = Application.get_all_env(:server)
    set_log_level(config)

    children = [
      worker(Chatme.Server.Listener, [config]),
      supervisor(Chatme.Server.ConnSup, []),
      supervisor(Chatme.Server.ConnRegistry, []),
    ]

    opts = [strategy: :one_for_one, name: Chatme.Server.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp set_log_level(config) do
    if config[:debug] do
      Logger.configure level: :debug
    end
  end
end
