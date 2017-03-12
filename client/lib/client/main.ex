defmodule Chatme.Client.Main do
  @moduledoc false

  alias Chatme.Client

  @defaults [server_ip: "127.0.0.1", server_port: 33_333, help: false]
  @help """
  Usage: server --name <name> --media <path> [--server-port <port>]
         [--server-ip <ip>] [--help]

    -n, --name          User's nickname
    -m, --media         Path to file with ASCII art to be sent as media
    -p, --server-port   Chat server port number
    -i, --server-ip     Chat server IP address
    -h, --help          Display this help message
  """
  @prompt "> "

  def main(args) do
    options = prepare_options(args)
    if options[:help] do
      IO.puts @help
    else
      start_client(options)
      input_loop()
    end
  end

  defp prepare_options(args) do
    args
    |> parse_args()
    |> validate_options()
    |> merge_with_defaults()
    |> translate_options()
    |> ensure_name_present()
    |> ensure_media_present()
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [server_port: :integer, server_ip: :string,
                 help: :boolean, name: :string, media: :string],
      aliases: [p: :server_port, i: :server_ip, h: :help, n: :name,
                m: :media])
    options
  end

  defp validate_options(options) do
    Enum.filter(options, &validate_option/1)
  end

  defp validate_option({:server_port, val}) when val in 0..65_535, do: true
  defp validate_option({:server_port, val}) do
    IO.puts """
    error: Invalid port number: #{inspect val}
    error: Falling back to default port number: #{@defaults[:server_port]}
    """
    false
  end
  defp validate_option({:server_ip, val}) do
    case val |> to_charlist() |> :inet.parse_address() do
      {:ok, _} -> true
      _ ->
        IO.puts """
        error: Invalid IP address: #{inspect val}
        error: Falling back to default IP address: #{@defaults[:server_ip]}
        """
        false
    end
  end
  defp validate_option({:help, val}) when is_boolean(val), do: true
  defp validate_option({:help, _}), do: false
  defp validate_option({:name, val}) when is_binary(val), do: true
  defp validate_option({:name, _}), do: false
  defp validate_option({:media, path}) when is_binary(path) do
    if File.regular?(path) do
      true
    else
      IO.puts "error: #{path} is not a regular file"
    end
  end

  defp merge_with_defaults(options) do
    @defaults |> Keyword.merge(options)
  end

  defp translate_options(options) do
    Enum.map(options, &translate_option/1)
  end

  defp translate_option({:server_ip, val}) do
    {:ok, ip} = val |> to_charlist() |> :inet.parse_address()
    {:server_ip, ip}
  end
  defp translate_option({:media, path}) do
    media = File.read!(path)
    {:media, media}
  end
  defp translate_option(kv), do: kv

  defp ensure_name_present(options) do
    if is_binary(options[:name]) do
      options
    else
      IO.puts "error: --name option is required"
      halt(1)
    end
  end

  defp ensure_media_present(options) do
    if is_binary(options[:media]) do
      options
    else
      IO.puts "error: --media option is required"
      halt(1)
    end
  end

  defp start_client(options) do
    case Client.start(options) do
      :ok ->
        monitor_client()
      {:error, _} ->
        halt(1)
    end
  end

  defp monitor_client do
    spawn fn ->
      ref = Process.monitor(Chatme.Client.Supervisor)
      monitor_loop(ref)
    end
  end

  defp monitor_loop(ref) do
    receive do
      {:DOWN, ^ref, _, _, _} ->
        halt(0)
      _ ->
        monitor_loop(ref)
    end
  end

  defp input_loop do
    message = handle_input()
    if not empty?(message) do
      message
      |> String.trim()
      |> send()
    end
    input_loop()
  end

  defp handle_input do
    case IO.gets(@prompt) do
      {:error, _} ->
        IO.puts "Bye!"
        halt(0)
      :eof ->
        IO.puts "Bye!"
        halt(0)
      input ->
        input
    end
  end

  defp empty?(message) do
    message =~ ~r/^\s.*$/
  end

  defp halt(code) do
    :init.stop(code)
    Process.sleep(:infinity)
  end

  defp send(message) do
    case message do
      "M" -> Client.send_media()
      _ -> Client.send(message)
    end
  end
end
