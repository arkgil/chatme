defmodule Chatme.Server.ConnSup do
  @moduledoc false

  def start_link do
    import Supervisor.Spec, warn: false

    children = [
      worker(Chatme.Server.Conn, [], restart: :temporary)
    ]

    opts = [strategy: :simple_one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
