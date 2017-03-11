defmodule Chatme.Server.Main do
  @moduledoc false

  @defaults [debug: false, ip: "127.0.0.1", port: 33_333]
  @help """
  Usage: server [--port <port>] [--ip <ip>] [--debug] [--help]

    -p, --port    Port number server will listen on
    -i, --ip      IP address server will bind to
    -d, --debug   Show debug messages
    -h, --help    Display this help message
  """

  def main(args) do
    options = prepare_options(args)
    if options[:help] do
      IO.puts @help
    else
      Chatme.Server.start(options)
      sleep()
    end
  end

  defp prepare_options(args) do
    args
    |> parse_args()
    |> validate_options()
    |> merge_with_defaults()
    |> translate_options()
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [debug: :boolean, port: :integer, ip: :string, help: :boolean],
      aliases: [d: :debug, p: :port, i: :ip, h: :help])
    options
  end

  defp validate_options(options) do
    Enum.filter(options, &validate_option/1)
  end

  defp validate_option({:debug, val}) when is_boolean(val), do: true
  defp validate_option({:debug, _}), do: false
  defp validate_option({:port, val}) when val in 0..65_535, do: true
  defp validate_option({:port, val}) do
    IO.puts """
    error: Invalid port number: #{inspect val}
    error: Falling back to default port number: #{@defaults[:port]}
    """
    false
  end
  defp validate_option({:ip, val}) do
    case val |> to_charlist() |> :inet.parse_address() do
      {:ok, _} -> true
      _ ->
        IO.puts """
        error: Invalid IP address: #{inspect val}
        error: Falling back to default IP address: #{@defaults[:ip]}
        """
        false
    end
  end
  defp validate_option({:help, val}) when is_boolean(val), do: true
  defp validate_option({:help, _}), do: false

  defp merge_with_defaults(options) do
    @defaults |> Keyword.merge(options)
  end

  defp translate_options(options) do
    Enum.map(options, &translate_option/1)
  end

  defp translate_option({:ip, val}) do
    {:ok, ip} = val |> to_charlist() |> :inet.parse_address()
    {:ip, ip}
  end
  defp translate_option(kv), do: kv

  defp sleep do
    receive do
      _ -> :ok
    end
  end
end
