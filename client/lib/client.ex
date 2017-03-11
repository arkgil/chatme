defmodule Chatme.Client do
  @moduledoc """
  TCP chat client
  """

  def start(config) do
    {:ok, _} = Application.ensure_all_started(:client, :permanent)
    Chatme.Client.Conn.start(config)
  end

  def send(message) do
    Chatme.Client.Conn.send(message)
  end
end
