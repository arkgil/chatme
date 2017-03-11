defmodule Chatme.Client.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
    ]

    opts = [strategy: :one_for_one, name: Chatme.Client.Supervisor,
            max_restarts: 0]
    Supervisor.start_link(children, opts)
  end
end
