defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    # Dispatch based on first byte of the bucket name
    first = :binary.first(bucket)

    # Find and entry of the bucket or fail
    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    # If the entry belongs to this node, execute it
    # otherwise dispatch it
    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      {KV.RouterTasks, elem(entry, 1)}
      |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
      |> Task.await()
    end
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect(bucket)} in table #{inspect(table())}"
  end

  @doc """
  The mock routing table.
  """
  def table do
    [{?a..?m, :"foo@POLOBEAR-DEB"}, {?n..?z, :"bar@POLOBEAR-DEB"}]
  end
end
