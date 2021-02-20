defmodule KVServer.Command do
  @doc ~S"""
  Parses the given `line` into a command.

  ## Examples

  You can create a bucket
    iex> KVServer.Command.parse("CREATE shopping\r\n")
    {:ok, {:create, "shopping"}}

  Trailing spaces won't matter
    iex> KVServer.Command.parse("CREATE   shopping  \r\n")
    {:ok, {:create, "shopping"}}

  You can put stuff in a bucket
    iex> KVServer.Command.parse("PUT shopping milk 2 \r\n")
    {:ok, {:put, "shopping", "milk", "2"}}

  You can retrieve the stuff you put
    iex> KVServer.Command.parse("GET shopping milk \r\n")
    {:ok, {:get, "shopping", "milk"}}

  You can delete stuff in a bucket
    iex> KVServer.Command.parse("DELETE shopping eggs \r\n")
    {:ok, {:delete, "shopping", "eggs"}}

  Unknown commands or commands with the wrong number of arguments will return an error:
    iex> KVServer.Command.parse("UNKNOWN shopping stuff \r\n")
    {:error, :unknown_command}

    iex> KVServer.Command.parse("GET shopping \r\n")
    {:error, :unknown_command}

  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["PUT", bucket, item, quantity] -> {:ok, {:put, bucket, item, quantity}}
      ["GET", bucket, item] -> {:ok, {:get, bucket, item}}
      ["DELETE", bucket, item] -> {:ok, {:delete, bucket, item}}
      _ -> {:error, :unknown_command}
    end
  end
end
