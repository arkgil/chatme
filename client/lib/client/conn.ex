defmodule Chatme.Client.Conn do
  @moduledoc """
  Process handling connection with the server
  """

  use GenServer

  import Chatme.Client.Utils

  require Logger

  @type state :: %{socket: :gen_tcp.socket,
                   server_ip: :inet.ip_address,
                   server_port: :inet.port_number,
                   name: String.t}
  ## API

  @doc """
  Starts client connection
  """
  def start(config) do
    import Supervisor.Spec, warn: false

    Supervisor.start_child(Chatme.Client.Supervisor,
      worker(__MODULE__, [config]))
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc """
  Returns local port of connection
  """
  def get_port do
    GenServer.call(__MODULE__, :get_port)
  end

  @doc """
  Sends data throught the connection
  """
  def send(data) do
    GenServer.cast(__MODULE__, {:send, data})
  end

  ## GenServer callbacks

  def init(config) do
    Logger.metadata tag: "[Conn]"
    server_ip = config[:server_ip]
    server_port = config[:server_port]
    name = config[:name]
    case init_socket(server_ip, server_port) do
      {:ok, socket} ->
        state = %{socket: socket,
                  server_ip: server_ip,
                  server_port: server_port,
                  name: name}
        Logger.info "Connected to server at " <>
          format_ip_and_port(server_ip, server_port)
        {:ok, state}
      {:error, reason} ->
        Logger.error "Couldn't connect to server at " <>
          format_ip_and_port(server_ip, server_port) <> ": #{inspect reason}"
        {:stop, reason}
    end
  end

  def handle_call(:get_port, _, %{socket: socket} = state) do
    {:ok, port} = :inet.port(socket)
    {:reply, port, state}
  end

  def handle_cast({:send, data}, state) do
    send_message(data, state)
    {:noreply, state}
  end

  def handle_info({:tcp, socket, data}, %{socket: socket} = state) do
    print(data)
    {:noreply, state}
  end
  def handle_info({:tcp_error, socket, reason}, %{socket: socket} = state) do
    Logger.error "Connection error: " <> inspect(reason)
    {:stop, reason, state}
  end
  def handle_info({:tcp_closed, socket}, %{socket: socket} = state) do
    Logger.info "Connection closed"
    {:stop, :normal, state}
  end

  ## Internal functions

  defp init_socket(ip, port) do
    :gen_tcp.connect(ip, port, [:binary, active: true])
  end

  defp print(data) do
    IO.puts data
  end

  defp send_message(data, %{socket: socket, name: name}) do
    message = "[#{name}] #{data}"
    case :gen_tcp.send(socket, message) do
      :ok -> :ok
      {:error, reason} ->
        Logger.error "Couldn't send message: #{inspect reason}"
    end
  end
end
