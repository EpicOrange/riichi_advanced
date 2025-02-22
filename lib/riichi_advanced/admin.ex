defmodule RiichiAdvanced.Admin do
  alias RiichiAdvanced.GameState.Log, as: Log
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # migrate on startup
    blue = String.to_atom(System.get_env("BLUE_SNAME", "nil"))
    green = String.to_atom(System.get_env("GREEN_SNAME", "nil"))
    # world class discovery mechanism right here
    case [blue, green] -- [node()] do
      [dst] ->
        GenServer.cast({RiichiAdvanced.Admin, dst}, {:migrate, node()})
      _     -> :ok
    end
    {:ok, %{}}
  end

  # hell yeah automated test case generation let's goooo
  # RiichiAdvanced.Utils.logs_to_test_case(["riichi"])
  def log_to_test_case(log_id, kyoku_index \\ nil) do
    # read in the log
    log_json = case File.read(Application.app_dir(:riichi_advanced, "/priv/static/logs/#{log_id <> ".json"}")) do
      {:ok, log_json} -> log_json
      {:error, _err}  -> nil
    end

    # decode the log json
    log = try do
      case Jason.decode(log_json) do
        {:ok, log} -> log
        {:error, err} ->
          IO.puts("WARNING: Failed to read log file at character position #{err.position}!\nRemember that trailing commas are invalid!")
          %{}
      end
    rescue
      ArgumentError -> 
        IO.puts("WARNING: Log \"#{log_id}\" doesn't exist!")
        %{}
    end

    # get ruleset and mods
    ruleset = log["rules"]["ruleset"]
    mods = Jason.encode!(log["rules"]["mods"])

    calls = for {kyoku, i} <- Enum.with_index(if kyoku_index == nil do log["kyokus"] else [Enum.at(log["kyokus"], kyoku_index)] end) do
      # get config
      starting_hands = kyoku["players"]
      |> Enum.with_index()
      |> Enum.map_join(",\n", fn {player, i} -> "    \"#{Log.from_seat(i)}\": #{Jason.encode!(player["haipai"])}" end)
      starting_draws = kyoku["wall"]
      |> Jason.encode!()
      starting_dead_wall = (Enum.reverse(kyoku["kan_tiles"]) ++ Enum.concat(Enum.zip_with(kyoku["uras"], kyoku["doras"], &[&1, &2])))
      |> Jason.encode!()

      # get event list
      events = kyoku["events"]
      # |> Enum.reduce({[], []}, fn event, {ret, skips} -> TODO end)
      # |> Enum.reverse()
      |> Enum.filter(& &1["type"] in ["discard", "buttons_pressed"]) # mark tiles not yet supported
      |> Enum.map(&Map.take(&1, ["type", "buttons", "tile", "tsumogiri"] ++ if &1["type"] == "buttons_pressed" do [] else ["player"] end))
      |> Enum.map_join(",\n  ", &inspect/1)

      # get round result, if any
      {winner_seat, yaku, yaku2, minipoints} = case Enum.at(kyoku["result"], 0) do
        nil -> {nil, [], [], 0}
        winner ->
          yaku = Enum.map_join(winner["yaku"], ", ", fn [name, value] -> inspect({name, value}) end)
          yaku2 = Enum.map_join(winner["yakuman"], ", ", fn [name, value] -> inspect({name, value}) end)
          minipoints = winner["fu"]
          {Log.from_seat(winner["seat"]), yaku, yaku2, minipoints}
      end

      """
      # kyoku #{i}:
      TestUtils.test_yaku_advanced("#{ruleset}", #{mods}, \"\"\"
      {
        "starting_hand": {
      #{starting_hands}
        },
        "starting_draws": #{starting_draws},
        "starting_dead_wall": #{starting_dead_wall}
      }
      \"\"\", [
        #{events}
      ], %{
        #{winner_seat}: %{
          yaku: [#{yaku}],
          yaku2: [#{yaku2}],
          minipoints: #{minipoints}
        }
      })
      """
      |> String.replace("\n", "\n  ")
    end
    |> Enum.join("\n  ")

    """
      # ===
    test "#{ruleset} - game #{log_id}" do
      #{calls}
    end

    """
    |> String.replace("\n", "\n  ")
  end
  def logs_to_test_case(log_ids) do
    log_ids
    |> Enum.map_join("\n", &log_to_test_case/1)
    |> IO.puts()
  end

  def handle_cast({:migrate, dst}, state) do
    try do
      if Node.connect(dst) == true do
        IO.puts("Pulling running games from #{inspect(dst)}")
        DynamicSupervisor.which_children(RiichiAdvanced.GameSessionSupervisor)
        |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
        |> Enum.map(&String.replace(&1, "game", "game_state"))
        |> Enum.map(&Registry.lookup(:game_registry, &1))
        |> Enum.map(fn [{pid, _}] -> pid end)
        |> Enum.each(&GenServer.cast(&1, {:respawn_on, dst}))
        DynamicSupervisor.which_children(RiichiAdvanced.GameSessionSupervisor)
        GenServer.cast(self(), :close_server)
      else
        IO.puts("Failed to connect to #{inspect(dst)}!")
      end
    rescue
      _ ->
        IO.puts("Not migrating")
        :ok
    end
    {:noreply, state}
  end

  def handle_cast(:close_server, state) do
    games = DynamicSupervisor.which_children(RiichiAdvanced.GameSessionSupervisor)
    if Enum.empty?(games) do
      System.stop(0)
    else
      # try again in 0.5s
      :timer.apply_after(500, GenServer, :cast, [self(), :close_server])
    end
    {:noreply, state}
  end

end