defmodule Chatme.Server do
  @moduledoc """
  TCP chat server
  """

  @doc false
  def start(options) do
    Application.load(:server)
    configure(options)
    {:ok, _} = Application.ensure_all_started(:server, :permanent)
  end

  defp configure(options) do
    Enum.each options, fn {k, v} ->
      Application.put_env :server, k, v
    end
  end
end
