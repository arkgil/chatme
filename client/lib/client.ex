defmodule Chatme.Client do
  @moduledoc """
  TCP chat client
  """

  def start(config) do
    with {:ok, _} <- Application.ensure_all_started(:client, :permanent),
         {:ok, _} <- Chatme.Client.Conn.start(config),
         {:ok, _} <- Chatme.Client.Media.start(config) do
      :ok
    end
  end

  def send(message) do
    Chatme.Client.Conn.send(message)
  end

  def send_media do
    Chatme.Client.Media.send()
  end
end
