defmodule Chatme.Server.Listener do
  @moduledoc """
  TCP listener and acceptor process
  """

  use GenServer

  alias Chatme.Server.Conn

  import Chatme.Server.Utils

  require Logger

  @type state :: %{ip: :inet.ip_address,
                   port: :inet.port_number,
                   socket: :gen_tcp.socket}

  ## API

  @doc """
  Starts listener process
  """
  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  ## GenServer callbacks

  def init(config) do
    Logger.metadata tag: "[Listener]"
    ip = config[:ip]
    port = config[:port]
    case init_socket(ip, port) do
      {:ok, socket} ->
        state = %{ip: ip, port: port, socket: socket}
        Logger.info "Started listening on " <> format_ip_and_port(ip, port)
        accept()
        {:ok, state}
      {:error, reason} ->
        Logger.error "Couldn't initialize listening socket: " <>
          inspect(reason)
        {:stop, reason}
    end
  end

  def handle_info(:accept, %{socket: socket} = state) do
    accept_conn(socket)
    accept()
    {:noreply, state}
  end

  ## Internal functions

  defp init_socket(ip, port) do
    :gen_tcp.listen(port, [:binary, ip: ip, active: true])
  end

  defp accept do
    send(self(), :accept)
  end

  defp accept_conn(socket) do
    with {:ok, conn_socket} <- :gen_tcp.accept(socket),
         {:ok, {remote_ip, remote_port}} <- :inet.peername(conn_socket),
         {:ok, conn_pid} <- Conn.start(conn_socket, remote_ip, remote_port),
         :ok <- :gen_tcp.controlling_process(conn_socket, conn_pid) do
      Logger.info "Accepted connection from " <>
        format_ip_and_port(remote_ip, remote_port)
    else
      {:error, reason} ->
        Logger.warn "Failed to accept connection: " <> inspect(reason)
    end
  end
end
