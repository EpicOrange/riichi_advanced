defmodule RiichiAdvanced.GameState.Saki do
  import RiichiAdvanced.GameState

  @supported_cards [
    "atarashi-ako",
    "choe-myeonghwa",
    "haramura-nodoka",
    "ikeda-kana",
    "jindai-komaki",
    "kakura-kurumi",
    "kataoka-yuuki",
    "mase-yuuko",
    "matano-seiko",
    "matsumi-kuro",
    "matsumi-yuu",
    "miyanaga-saki",
    "miyanaga-teru",
    "nanpo-kazue",
    "sagimori-arata",
    "sawamura-tomoki",
    "senoo-kaori",
    "shibuya-takami",
    "takakamo-shizuno",
    "takei-hisa",
    "takimi-haru",
    "toyouko-mokmoko",
    "toyouko-momoko",
    "usuzawa-sae",
    "usuzumi-hatsumi",
    "yumeno-maho"
  ]

  def initialize_saki(state) do
    state = if not Map.has_key?(state.rules, "saki_deck") do
      show_error(state, """
      Expected rules file to have key \"saki_deck\".

      This should be an array of supported saki cards. Example:

        \"saki_deck\": ["amae-koromo", "miyanaga-saki"]
      """)
    else state end
    
    state = Map.put(state, :saki, %{
      saki_deck: Enum.shuffle(state.rules["saki_deck"]),
      saki_deck_index: 0,
      all_drafted: false,
      picking_discards: nil,
      marking_player: nil,
      # for example marked_objects = 
      # {
      #   hand: {
      #     marked: [{:"2m", :east, 4}],
      #     needed: 1,
      #     restrictions: ["same_suit_as_marked_discard"]
      #   },
      #   discard: {
      #     marked: [],
      #     needed: 1,
      #     restrictions: ["same_suit_as_marked_hand"]
      #   },
      # }
      marked_objects: %{}
    })

    state
  end

  def draw_saki_cards(state, num) do
    ix = state.saki.saki_deck_index
    cards = Enum.slice(state.saki.saki_deck, ix..ix+num-1)
    state = Map.update!(state, :saki, &Map.put(&1, :saki_deck_index, ix + num))
    {state, cards}
  end

  def check_if_all_drafted(state) do
    all_drafted = Enum.all?(state.players, fn {_seat, player} ->
      Enum.any?(player.status, fn status -> status in @supported_cards end)
    end)
    if all_drafted do
      state = Map.update!(state, :saki, &Map.put(&1, :all_drafted, true))
      state = Map.put(state, :game_active, true)
      state
    else state end
  end

  def filter_cards(statuses) do
    Enum.filter(statuses, fn status -> status in @supported_cards end)
  end

  def setup_marking(state, seat, to_mark) do
    state = put_in(state.saki.marking_player, seat)
    state = put_in(state.saki.marked_objects, for {target, amount, restrictions} <- to_mark, reduce: %{} do
      marked -> case target do
        "hand"    -> Map.put(marked, :hand, %{marked: [], needed: amount, restrictions: restrictions})
        "discard" -> Map.put(marked, :discard, %{marked: [], needed: amount, restrictions: restrictions})
        _         ->
          GenServer.cast(self(), {:show_error, "Unknown mark target: #{inspect(target)}"})
          marked
      end
    end)
    state
  end

  def needs_marking(state) do
    Enum.any?(state.saki.marked_objects, fn {_source, mark_info} -> length(mark_info.marked) < mark_info.needed end)
  end

  defp get_tile(state, seat, index, source) do
    case source do
      :hand    -> state.players[seat].hand ++ state.players[seat].draw |> Enum.at(index)
      :discard -> state.players[seat].pond |> Enum.at(index)
      _        ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        nil
    end
  end

  def can_mark(state, seat, index, source) do
    tile = get_tile(state, seat, index, source)
    mark_info = state.saki.marked_objects[source]
    marked_enough = mark_info != nil && length(mark_info.marked) >= mark_info.needed
    already_marked = is_marked(state, seat, index, source)
    mark_info != nil && not marked_enough && not already_marked && Enum.all?(mark_info.restrictions, fn restriction ->
      case restriction do
        "match_suit" ->
          case source do
            :hand    ->
              case state.saki.marked_objects.discard.marked do
                []                  -> Riichi.is_suited?(tile)
                [{tile2, _, _} | _] ->
                  IO.puts("Checking if same suit: #{inspect(tile)}, #{inspect(tile2)}")
                  Riichi.same_suit?(tile, tile2)
              end
            :discard -> 
              case state.saki.marked_objects.hand.marked do
                []                  -> Riichi.is_suited?(tile)
                [{tile2, _, _} | _] ->
                  IO.puts("Checking if same suit: #{inspect(tile)}, #{inspect(tile2)}")
                  Riichi.same_suit?(tile, tile2)
              end
            _        ->
              GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
              true
          end
        _            ->
          GenServer.cast(self(), {:show_error, "Unknown restriction: #{inspect(restriction)}"})
          true
      end
    end)
  end

  def is_marked(state, seat, index, source) do
    case source do
      :hand    -> Map.has_key?(state.saki.marked_objects, :hand) && Enum.any?(state.saki.marked_objects.hand.marked, fn {_tile, seat2, index2} -> seat == seat2 && index == index2 end)
      :discard -> Map.has_key?(state.saki.marked_objects, :discard) && Enum.any?(state.saki.marked_objects.discard.marked, fn {_tile, seat2, index2} -> seat == seat2 && index == index2 end)
      _        ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        false
    end
  end

  def mark_tile(state, seat, index, source) do
    case source do
      :hand    -> update_in(state.saki.marked_objects.hand.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), seat, index}] end)
      :discard -> update_in(state.saki.marked_objects.discard.marked, fn marked -> marked ++ [{get_tile(state, seat, index, source), seat, index}] end)
      _        ->
        GenServer.cast(self(), {:show_error, "Unknown mark source: #{inspect(source)}"})
        state
    end
  end

  def clear_marked_objects(state) do
    update_in(state.saki.marked_objects, &Map.new(&1, fn {source, mark_info} -> {source, Map.put(mark_info, :marked, [])} end))
  end

  def reset_marking(state) do
    state = put_in(state.saki.marking_player, nil)
    state = put_in(state.saki.marked_objects, %{})
    state
  end
end