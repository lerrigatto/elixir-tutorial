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

  @doc """
  Runs the given command.
  """
  def run(command)

  def run({:create, bucket}) do
    case KV.Router.route(bucket, KV.Registry, :create, [KV.Registry, bucket]) do
      pid when is_pid(pid) -> {:ok, "OK!\r\n"}
      _ -> {:error, "FAILED TO CREATE BUCKET"}
    end
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      value = KV.Bucket.get(pid, key)
      {:ok, "#{value}\r\nOK!\r\n"}
    end)
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid ->
      KV.Bucket.put(pid, key, value)
      {:ok, "OK!\r\n"}
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid ->
      KV.Bucket.delete(pid, key)
      {:ok, "OK!\r\n"}
    end)
  end

  defp lookup(bucket, callback) do
    case KV.Router.route(bucket, KV.Registry, :lookup, [KV.Registry, bucket]) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
