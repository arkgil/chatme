defmodule Chatme.Client.Media do
  @moduledoc """
  Process handling media transfer to server via UDP
  """

  use GenServer

  import Chatme.Client.Utils

  alias Chatme.Client.Conn

  require Logger

  @type state :: %{socket: :gen_udp.socket,
                   server_ip: :inet.ip_address,
                   server_port: :inet.port_number,
                   media: String.t,
                   name: String.t}

  ## API

  @doc """
  Starts media channel
  """
  def start(config) do
    import Supervisor.Spec, warn: false

    Supervisor.start_child(Chatme.Client.Supervisor,
      worker(__MODULE__, [config]))
  end

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def send do
    GenServer.cast(__MODULE__, :send)
  end

  ## GenServer callbacks

  def init(config) do
    Logger.metadata tag: "[Media]"
    server_ip = config[:server_ip]
    server_port = config[:server_port]
    media = config[:media]
    name = config[:name]
    port = Conn.get_port()
    case init_socket(port) do
      {:ok, socket} ->
        state = %{socket: socket,
                  server_ip: server_ip,
                  server_port: server_port,
                  media: media,
                  name: name}
        Logger.info "Opened media channel to " <>
          format_ip_and_port(server_ip, server_port)
        {:ok, state}
      {:error, reason} ->
        Logger.error "Couldn't open media channel to " <>
          format_ip_and_port(server_ip, server_port) <> ": #{inspect reason}"
        {:stop, reason}
    end
  end

  def handle_cast(:send, state) do
    print "\n" <> state.media
    send_media(state)
    {:noreply, state}
  end

  def handle_info({:udp, socket, server_ip, server_port, media},
    %{socket: socket, server_ip: server_ip,
      server_port: server_port} = state) do
    print(media)
    {:noreply, state}
  end

  ## Internal functions

  defp init_socket(port) do
    :gen_udp.open(port)
  end

  defp print(media) do
    IO.puts media
  end

  defp send_media(%{socket: socket, server_ip: server_ip, media: media,
                    name: name, server_port: server_port,}) do
    payload = "[#{name}] Sends media:\n" <> media
    :gen_udp.send(socket, server_ip, server_port, payload)
  end
end
