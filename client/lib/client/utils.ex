defmodule Chatme.Client.Utils do
  @moduledoc """
  Cross-module utilities
  """

  @doc """
  Translates IP and port number to string
  """
  def format_ip_and_port(ip, port) do
    [:inet.ntoa(ip), ":", to_string(port)] |> :erlang.iolist_to_binary()
  end
end
