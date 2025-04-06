defmodule RiichiAdvanced.Admin do
  alias RiichiAdvanced.GameState.American, as: American
  alias RiichiAdvanced.GameState.Log, as: Log
  alias RiichiAdvanced.GameState.TileBehavior, as: TileBehavior
  alias RiichiAdvanced.Utils, as: Utils
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
  # RiichiAdvanced.Admin.logs_to_test_case(["riichi"])
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
    mods = Enum.map_join(log["rules"]["mods"], ", ", &case &1 do
      %{"name" => name, "config" => config} -> "%{name: \"#{name}\", config: #{inspect(config, limit: :infinity)}}"
      name -> "\"#{name}\""
    end)

    calls = for {kyoku, i} <- (if kyoku_index == nil do Enum.with_index(log["kyokus"]) else [{Enum.at(log["kyokus"], kyoku_index), kyoku_index}] end) do
      # get config
      starting_hands = kyoku["players"]
      |> Enum.with_index()
      |> Enum.map_join(",\n", fn {player, i} -> "    \"#{Log.from_seat(i)}\": #{Jason.encode!(player["haipai"])}" end)
      starting_draws = kyoku["wall"]
      |> Jason.encode!()
      starting_dead_wall = (kyoku["kan_tiles"] ++ Enum.concat(Enum.zip_with(kyoku["doras"], kyoku["uras"], &[&1, &2])))
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
      TestUtils.test_yaku_advanced("#{ruleset}", [#{mods}], \"\"\"
      {
        "starting_hand": {
      #{starting_hands}
        },
        "starting_draws": #{starting_draws},
        "starting_dead_wall": #{starting_dead_wall},
        "starting_round": #{kyoku["kyoku"]},
        "starting_honba": #{kyoku["honba"]}
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
    |> Enum.map_join("\n", &case &1 do
      {log_id, kyoku} -> log_to_test_case(log_id, kyoku)
      log_id -> log_to_test_case(log_id)
    end)
    |> IO.puts()
  end

  @am_wall [:"1m", :"1m", :"1m", :"1m", :"2m", :"2m", :"2m", :"2m", :"3m", :"3m", :"3m", :"3m", :"4m", :"4m", :"4m", :"4m", :"5m", :"5m", :"5m", :"5m", :"6m", :"6m", :"6m", :"6m", :"7m", :"7m", :"7m", :"7m", :"8m", :"8m", :"8m", :"8m", :"9m", :"9m", :"9m", :"9m", :"1p", :"1p", :"1p", :"1p", :"2p", :"2p", :"2p", :"2p", :"3p", :"3p", :"3p", :"3p", :"4p", :"4p", :"4p", :"4p", :"5p", :"5p", :"5p", :"5p", :"6p", :"6p", :"6p", :"6p", :"7p", :"7p", :"7p", :"7p", :"8p", :"8p", :"8p", :"8p", :"9p", :"9p", :"9p", :"9p", :"1s", :"1s", :"1s", :"1s", :"2s", :"2s", :"2s", :"2s", :"3s", :"3s", :"3s", :"3s", :"4s", :"4s", :"4s", :"4s", :"5s", :"5s", :"5s", :"5s", :"6s", :"6s", :"6s", :"6s", :"7s", :"7s", :"7s", :"7s", :"8s", :"8s", :"8s", :"8s", :"9s", :"9s", :"9s", :"9s", :"1z", :"1z", :"1z", :"1z", :"2z", :"2z", :"2z", :"2z", :"3z", :"3z", :"3z", :"3z", :"4z", :"4z", :"4z", :"4z", :"0z", :"0z", :"0z", :"0z", :"6z", :"6z", :"6z", :"6z", :"7z", :"7z", :"7z", :"7z", :"1f", :"2f", :"3f", :"4f", :"1g", :"2g", :"3g", :"4g"]
  # use like this:
  # ["222a 000 2222b 4444b"] |> Enum.each(&RiichiAdvanced.Admin.instantiate_am_hand/1)
  def instantiate_am_hand(hand) do
    hands = American.translate_american_match_definitions([hand])
    |> Enum.map(&American.instantiate_match_definition(&1, @am_wall, [], :"1p", %TileBehavior{}))
    |> Enum.map(fn
      nil -> []
      {a, b} -> Utils.sort_tiles(a ++ b)
    end)
    |> Enum.map(&Utils.hand_to_string/1)
    |> Enum.map(fn
      <<"11111f" <> rest>> -> "1234f1g" <> rest
      <<"1111f" <> rest>> -> "1234f" <> rest
      <<"111f" <> rest>> -> "123f" <> rest
      <<"11f" <> rest>> -> "12f" <> rest
      x -> x
    end)
    ["    # #{hand}" | Enum.map(hands, &"TestUtils.assert_winning_hand(rules_ref, \"win\", \"#{&1}\", \"\", @am_aliases)")]
    |> Enum.join("\n    ")
    |> IO.puts()
  end


  def handle_cast({:migrate, dst}, state) do
    try do
      if Node.connect(dst) == true do
        IO.puts("Pushing running games to #{inspect(dst)}")
        DynamicSupervisor.which_children(RiichiAdvanced.GameSessionSupervisor)
        |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
        |> Enum.map(&String.replace(&1, "game", "game_state"))
        |> Enum.map(&Registry.lookup(:game_registry, &1))
        |> Enum.map(fn [{pid, _}] -> pid end)
        |> Enum.each(&GenServer.cast(&1, {:respawn_on, dst}))
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