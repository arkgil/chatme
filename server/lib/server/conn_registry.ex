defmodule Chatme.Server.ConnRegistry do
  @moduledoc """
  Registry of client processes
  """

  @registry __MODULE__

  @doc """
  Starts the registry
  """
  def start_link do
    Registry.start_link(:duplicate, __MODULE__)
  end

  @doc """
  Registers connection in registry
  """
  def register(ip, port) do
    {:ok, _} = Registry.register(@registry, :conn, %{ip: ip, port: port})
  end

  @doc """
  Invokes given 2-argument function on each registered connection pid
  and associated value
  """
  def dispatch(fun) do
    sender = self()
    Registry.dispatch(@registry, :conn, fn entries ->
      for {pid, value} <- entries, pid != sender do
        fun.(pid, value)
      end
    end)
  end

  @doc """
  Checks if there is established connection with given
  IP and por
  """
  def conn_exists?(ip, port) do
    @registry
    |> Registry.lookup(:conn)
    |> Enum.any?(fn {_, %{ip: ^ip, port: ^port}} -> true
                    _ -> false
    end)
  end
end
