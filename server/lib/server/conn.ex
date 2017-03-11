defmodule Chatme.Server.Conn do
  @moduledoc """
  Process handling TCP connection with client
  """

  use GenServer

  alias Chatme.Server.ConnRegistry

  import Chatme.Server.Utils

  require Logger

  @type state :: %{socket: :gen_tcp.socket,
                   ip: :inet.ip_address,
                   port: :inet.port_number}

  ## API

  @doc """
  Starts connection process

  Only process owning a socket can call this function, i.e. Listener.
  """
  def start(socket, ip, port) do
    Supervisor.start_child(Chatme.Server.ConnSup, [socket, ip, port])
  end

  @doc false
  def start_link(socket, ip, port) do
    GenServer.start_link(__MODULE__, {socket, ip, port})
  end

  ## GenServer callbacks

  def init({socket, ip, port}) do
    state = %{
      socket: socket,
      ip: ip,
      port: port
    }
    ConnRegistry.register()
    Logger.metadata(tag: "[Conn][" <> format_ip_and_port(ip, port) <> "]")
    {:ok, state}
  end

  def handle_info({:tcp, socket, data}, %{socket: socket} = state) do
    Logger.debug "Received data: " <> data
    send_to_peers(data)
    {:noreply, state}
  end
  def handle_info({:tcp_error, socket, reason}, %{socket: socket} = state) do
    Logger.error "Connection error: " <> inspect(reason)
    {:stop, reason, state}
  end
  def handle_info({:tcp_closed, socket}, %{socket: socket} = state) do
    Logger.error "Connection closed"
    {:stop, :normal, state}
  end
  def handle_info({:peer_data, data}, %{socket: socket} = state) do
    case :gen_tcp.send(socket, data) do
      :ok ->
        {:noreply, state}
      {:error, reason} ->
        Logger.error "Couldn't send data from peer to client: " <> inspect(reason)
    end
  end

  ## Internal functions

  defp send_to_peers(data) do
    ConnRegistry.dispatch fn pid, _ ->
      send pid, {:peer_data, data}
    end
  end
end
