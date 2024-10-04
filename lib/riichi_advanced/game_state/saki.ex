defmodule RiichiAdvanced.GameState.Saki do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
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
    "onjouji-toki",
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
    "yumeno-maho",
    "amae-koromo",
  ]

  def initialize_saki(state) do
    state = if not Map.has_key?(state.rules, "saki_ver") do
      show_error(state, """
      Expected rules file to have key \"saki_ver\".

      Supported versions: "v12", "v13"
      """)
    else state end
    
    state = if not Map.has_key?(state.rules, "saki_deck") do
      show_error(state, """
      Expected rules file to have key \"saki_deck\".

      This should be an array of supported saki cards. Example:

        \"saki_deck\": ["amae-koromo", "miyanaga-saki"]
      """)
    else state end
    
    state = Map.put(state, :saki, %{
      version: state.rules["saki_ver"],
      saki_deck: Enum.shuffle(state.rules["saki_deck"]),
      saki_deck_index: 0,
      just_finished_second_row_discards: false,
      already_finished_second_row_discards: false
    })

    state
  end

  def draw_saki_cards(state, num) do
    ix = state.saki.saki_deck_index
    cards = Enum.slice(state.saki.saki_deck, ix..ix+num-1)
    state = Map.update!(state, :saki, &Map.put(&1, :saki_deck_index, ix + num))
    {state, cards}
  end

  def draft_saki_card(state, seat, choice) do
    state = update_player(state, seat, &%Player{ &1 | status: Enum.uniq(&1.status ++ [choice]), call_buttons: %{} })
    state = if check_if_all_drafted(state) do
      state = Map.put(state, :game_active, true)

      # run after_saki_start actions
      state = if Map.has_key?(state.rules, "after_saki_start") do
        Actions.run_actions(state, state.rules["after_saki_start"]["actions"], %{seat: state.turn})
      else state end

      state = Buttons.recalculate_buttons(state)
      notify_ai(state)
      state
    else state end
    state
  end

  def check_if_all_drafted(state) do
    Enum.all?(state.players, fn {_seat, player} ->
      Enum.any?(player.status, fn status -> status in @supported_cards end)
    end)
  end

  def filter_cards(statuses) do
    Enum.filter(statuses, fn status -> status in @supported_cards end)
  end
end