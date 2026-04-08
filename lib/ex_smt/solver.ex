defmodule ExSMT.Solver do
  use GenServer

  def start_link(init_data) do
    # IO.puts("Starting z3 solver for #{inspect(Keyword.get(init_data, :room_code))} #{inspect(Keyword.get(init_data, :ruleset))}")
    GenServer.start_link(__MODULE__, [], name: Keyword.get(init_data, :name))
  end

  def init(_state) do
    {:ok, z3} = ExCmd.Process.start_link(~w(z3 -smt2 -in))

    # ex_cmd doesn't want you to trap exit, so don't do that
    # unless you are debugging
    # Process.flag(:trap_exit, true)

    {:ok, %{process: z3}}
  end

  # this is the main thing you call
  def handle_call({:query, query, reset?}, _from, %{process: z3} = state) do
    msg = mk_msg(query, reset?, true)
    # |> IO.inspect(label: "call")
    ExCmd.Process.write(z3, msg)
    {:ok, out} = poll_z3(z3, "")
    ret = out
    |> String.split("\n", trim: true)
    {:reply, {:ok, ret}, state}
  end

  # this is for when you need no reply
  def handle_cast({:query, query, reset?}, %{process: z3} = state) do
    msg = mk_msg(query, reset?, false)
    # |> IO.inspect(label: "cast")
    ExCmd.Process.write(z3, msg)
    {:noreply, state}
  end

  # this is called exclusively when z3 crashes, but requires trapping exits
  def handle_info({:EXIT, _pid, reason}, state) do
    IO.inspect(reason, label: "Z3 crashed with reason")
    {:noreply, state}
  end

  @eot "__EOT__"
  def mk_msg(query, reset?, eot?), do: [
      if reset? do "(reset)\n" else "" end,
      query,
      "\n",
      if eot? do "(echo \"#{@eot}\")\n" else "" end
    ]

  def poll_z3(z3, acc) do
    case ExCmd.Process.read(z3) do
      {:ok, output} ->
        acc = String.trim_trailing(acc <> "\n" <> output) # support \r\n and \n
        if String.ends_with?(acc, @eot) do
          {:ok, String.slice(acc, 0, byte_size(acc) - byte_size(@eot))}
        else
          poll_z3(z3, acc)
        end
      err -> {:error, err}
    end
  end

  def terminate(_reason, %{process: z3}) do
    ExCmd.Process.close_stdin(z3)
    ExCmd.Process.await_exit(z3)
  end

end
