defmodule ExSMT.Solver do
  require Logger

  def start_link(init_data) do
    # IO.puts("Starting z3 solver for #{inspect(Keyword.get(init_data, :room_code))} #{inspect(Keyword.get(init_data, :ruleset))}")
    state = %{
      room_code: Keyword.get(init_data, :room_code),
      ruleset: Keyword.get(init_data, :ruleset)
    }
    GenServer.start_link(__MODULE__, state, name: Keyword.get(init_data, :name))
  end

  # def stop do
  #   case GenServer.whereis(__MODULE__) do
  #     pid when is_pid(pid) ->
  #       GenServer.call(pid, :graceful_stop, :infinity)
  #       :ok = Supervisor.terminate_child(ExSMT.Supervisor, __MODULE__)
  #       true
  #     nil ->
  #       false
  #   end
  # end

  # def restart do
  #   case GenServer.whereis(__MODULE__) do
  #     nil ->
  #       Supervisor.restart_child(ExSMT.Supervisor, __MODULE__)
  #     pid when is_pid(pid) ->
  #       GenServer.call(pid, :graceful_stop, :infinity)
  #   end
  # end

  # def alive? do
  #   case GenServer.whereis(__MODULE__) do
  #     nil -> false
  #     pid when is_pid(pid) -> GenServer.call(__MODULE__, :alive?, 5000)
  #   end
  # end

  # def query(iodata, reset \\ true) do
  #   case GenServer.whereis(__MODULE__) do
  #     nil -> {:error, :not_running}
  #     pid when is_pid(pid) ->
  #       {:ok, response_lns} = GenServer.call(__MODULE__, {:query, iodata, reset}, 5000)
  #       ExSMT.Solver.ResponseParser.parse(response_lns)
  #   end
  # end

  # def query_continue(iodata) do
  #   query(iodata, false)
  # end

  use GenServer

  defstruct [
    mode: :not_running,
    process: nil,
    launch_cfg: %{},
    queries: :queue.new(),
    reply: nil
  ]

  def init(_state) do
    opts = Map.new(Application.get_env(:ex_smt, :z3, []))

    z3_path = case Map.fetch(opts, :path) do
      {:ok, path} ->
        path = Path.expand(path)
        cond do
          File.dir?(path) ->
            {:prefix, path}
          File.regular?(path) ->
            {:binary, path}
        end
      :error ->
        case :os.find_executable(~c"z3") do
          chars when is_list(chars) ->
            {:binary, IO.iodata_to_binary(chars)}
          false ->
            {:prefix, Path.join([:code.priv_dir(:ex_smt), "z3"])}
        end
    end

    z3_bin_path = case z3_path do
      {:prefix, prefix} ->
        Path.join([prefix, "bin", "z3"])
      {:binary, bin_path} ->
        case File.read_link(bin_path) do
          {:ok, real_path} -> Path.expand(real_path, Path.dirname(bin_path))
          {:error, :einval} -> Path.expand(bin_path)
        end
    end
    
    # make sure that this genserver calls terminate() when killed
    Process.flag(:trap_exit, true)

    if File.regular?(z3_bin_path) do
      launch_cfg = %{
        binary: z3_bin_path,
      }

      {:ok, %__MODULE__{launch_cfg: launch_cfg}, {:continue, :first_start}}
    else
      :ignore
    end
  end

  def handle_continue(:first_start, %{mode: :not_running} = state0) do
    state1 = do_start_node(state0)
    {:noreply, state1}
  end

  def handle_continue(:restart_after_error, %{mode: :not_running} = state0) do
    state1 = do_start_node(state0)
    {:noreply, state1}
  end

  def handle_call(:alive?, _from, %{mode: :not_running} = state) do
    {:reply, false, state}
  end
  def handle_call(:alive?, _from, %{mode: :running} = state) do
    {:reply, true, state}
  end

  def handle_call({:query, _, _}, _from, %{mode: :not_runinng} = state) do
    {:reply, {:error, :not_running}, state}
  end
  def handle_call({:query, iodata, reset}, from, %{mode: :running, process: proc, queries: q} = state) do
    script = [
      if reset do "(reset)\n" else "" end,
      iodata, "\n",
      "(echo \"__EOT__\")\n"
    ]
    # Logger.debug(["writing:\n", script])
    Porcelain.Process.send_input(proc, script)
    {:noreply, %{state | queries: :queue.in(from, q)}}
  end

  def handle_call(:graceful_stop, _from, state) do
    {:stop, :normal, :ok, state}
  end

  def handle_info({_from, :data, :out, iodata}, %{reply: nil, queries: q} = state) do
    case :queue.out(q) do
      {:empty, _} ->
        log_ln = IO.iodata_to_binary(iodata)
        Logger.info(IO.ANSI.format([:blue, "z3: ", :reset, inspect(log_ln)]))
        {:noreply, state}
      {{:value, waiter}, new_q} ->
        reply = handle_reply_chunk(iodata, {waiter, []})
        {:noreply, %{state | queries: new_q, reply: reply}}
    end
  end
  def handle_info({_from, :data, :out, iodata}, %{reply: reply0} = state) do
    reply1 = handle_reply_chunk(iodata, reply0)
    {:noreply, %{state | reply: reply1}}
  end

  def handle_info({_from, :data, :err, iodata}, state) do
    log_ln = IO.iodata_to_binary(iodata) |> String.trim()
    Logger.error(IO.ANSI.format([:red, "z3: ", :reset, log_ln]))
    {:noreply, state}
  end

  def handle_info({_from, :result, %Porcelain.Result{status: 0}}, %{mode: :running} = state), do:
    {:noreply, %{state | mode: :not_running, process: nil}}
  def handle_info({_from, :result, %Porcelain.Result{status: status}}, %{mode: :running} = state) do
    Logger.error("z3 terminated with exit-code #{status}")
    {:noreply, %{state | mode: :not_running, process: nil}, {:continue, :restart_after_error}}
  end

  def handle_info({_from, :result, _result}, %{mode: :not_running} = state) do
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("z3: got other msg: #{inspect msg}")
    {:noreply, state}
  end

  def terminate(_reason, %{mode: :not_running}), do:
    :ok
  def terminate(_reason, %{mode: :running, process: proc}) do
    Porcelain.Process.stop(proc)
  end

  defp do_start_node(%{mode: :not_running, launch_cfg: launch_cfg} = state0) do
    proc = Porcelain.spawn(
      launch_cfg.binary,
      ["-smt2", "-in"],
      in: :receive,
      out: {:send, self()},
      err: {:send, self()},
      result: :keep
    )

    %{state0 | mode: :running, process: proc}
  end

  defp handle_reply_chunk(iodata, {waiter, prev_lns}) do
    {:ok, reply_lns} =
      IO.iodata_to_binary(iodata)
      |> StringIO.open(fn io ->
        IO.stream(io, :line)
        |> Stream.filter(&not(match?("\n", &1)))
        |> Enum.to_list()
      end)

    handle_reply_lines(reply_lns, prev_lns, waiter)
  end

  defp handle_reply_lines([], acc, waiter) do
    {waiter, acc}
  end
  defp handle_reply_lines(["__EOT__\n"], acc, waiter) do
    response_lns = Enum.reverse(acc)
    # Logger.debug(["read back:\n", response_lns])
    GenServer.reply(waiter, {:ok, response_lns})
    nil
  end
  defp handle_reply_lines([ln | lns], acc, waiter) do
    handle_reply_lines(lns, [ln | acc], waiter)
  end
end
