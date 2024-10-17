defmodule RiichiAdvanced.GameState.Saki do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Log, as: Log
  import RiichiAdvanced.GameState

  @card_names %{
    "aislinn-wishart" => "Aislinn Wishart",
    "anetai-toyone" => "Anetai Toyone",
    "arakawa-kei" => "Arakawa Kei",
    "amae-koromo" => "Amae Koromo",
    "atarashi-ako" => "Atarashi Ako",
    "choe-myeonghwa" => "Choe Myeonghwa",
    "haramura-nodoka" => "Haramura Nodoka",
    "ikeda-kana" => "Ikeda Kana",
    "jindai-komaki" => "Jindai Komaki",
    "kakura-kurumi" => "Kakura Kurumi",
    "kataoka-yuuki" => "Kataoka Yuuki",
    "mase-yuuko" => "Mase Yuuko",
    "matano-seiko" => "Matano Seiko",
    "matsumi-kuro" => "Matsumi Kuro",
    "matsumi-yuu" => "Matsumi Yuu",
    "miyanaga-saki" => "Miyanaga Saki",
    "miyanaga-teru" => "Miyanaga Teru",
    "nanpo-kazue" => "Nanpo Kazue",
    "onjouji-toki" => "Onjouji Toki",
    "sagimori-arata" => "Sagimori Arata",
    "sawamura-tomoki" => "Sawamura Tomoki",
    "senoo-kaori" => "Senoo Kaori",
    "shibuya-takami" => "Shibuya Takami",
    "takakamo-shizuno" => "Takakamo Shizuno",
    "takei-hisa" => "Takei Hisa",
    "takimi-haru" => "Takimi Haru",
    "toyouko-mokmoko" => "Toyouko Mokmoko",
    "toyouko-momoko" => "Toyouko Momoko",
    "usuzawa-sae" => "Usuzawa Sae",
    "usuzumi-hatsumi" => "Usuzumi Hatsumi",
    "yumeno-maho" => "Yumeno Maho",
  }

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
    push_message(state, [
      %{text: "Player #{seat} #{state.players[seat].nickname} chose "},
      %{bold: true, text: "#{@card_names[choice]}"}
    ])
    state = Log.log(state, seat, :saki_card, %{card: choice})

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
      Enum.any?(player.status, fn status -> Map.has_key?(@card_names, status) end)
    end)
  end

  def filter_cards(statuses) do
    Enum.filter(statuses, fn status -> Map.has_key?(@card_names, status) end)
  end
end