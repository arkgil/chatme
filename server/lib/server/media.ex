defmodule Chatme.Server.Media do
  @moduledoc """
  UDP media channel process
  """

  use GenServer

  import Chatme.Server.Utils

  alias Chatme.Server.ConnRegistry

  require Logger

  @type state :: %{ip: :inet.ip_address,
                   port: :inet.port_number,
                   socket: :gen_udp.socket}

  ## API

  @doc """
  Starts media channel process
  """
  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  ## GenServer callbacks

  def init(config) do
    Logger.metadata tag: "[Media]"
    ip = config[:ip]
    port = config[:port]
    case init_socket(ip, port) do
      {:ok, socket} ->
        state = %{ip: ip, port: port, socket: socket}
        Logger.info "Opened media channel on " <> format_ip_and_port(ip, port)
        {:ok, state}
      {:error, reason} ->
        Logger.error "Couldn't open media channel: #{inspect reason}"
        {:stop, reason}
    end
  end

  def handle_info({:udp, socket, remote_ip, remote_port, media},
    %{socket: socket} = state) do
    broadcast_media(socket, media, remote_ip, remote_port)
    {:noreply, state}
  end

  ## Internal functions

  def init_socket(ip, port) do
    :gen_udp.open(port, [:binary, active: true, ip: ip])
  end

  defp broadcast_media(socket, media, remote_ip, remote_port) do
    if ConnRegistry.conn_exists?(remote_ip, remote_port) do
      Logger.debug "Received media from " <>
        format_ip_and_port(remote_ip, remote_port)
      ConnRegistry.dispatch fn _, %{ip: ip, port: port} ->
        if ip != remote_ip || port != remote_port do
          :gen_udp.send(socket, ip, port, media)
        end
      end
    end
  end
end
