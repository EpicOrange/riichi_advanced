defmodule RiichiAdvanced.GameState.Saki do
  alias RiichiAdvanced.GameState.Actions, as: Actions
  alias RiichiAdvanced.GameState.Buttons, as: Buttons
  alias RiichiAdvanced.GameState.Debug, as: Debug
  alias RiichiAdvanced.GameState.Player, as: Player
  alias RiichiAdvanced.GameState.Rules, as: Rules
  import RiichiAdvanced.GameState

  @card_names %{
    "aislinn-wishart" => "Aislinn Wishart",
    "amae-koromo" => "Amae Koromo",
    "anetai-toyone" => "Anetai Toyone",
    "arakawa-kei" => "Arakawa Kei",
    "atago-hiroe" => "Atago Hiroe",
    "atago-kinue" => "Atago Kinue",
    "atarashi-ako" => "Atarashi Ako",
    "choe-myeonghwa" => "Choe Myeonghwa",
    "ezaki-hitomi" => "Ezaki Hitomi",
    "fukuji-mihoko" => "Fukuji Mihoko",
    "funakubo-hiroko" => "Funakubo Hiroko",
    "hanada-kirame" => "Hanada Kirame",
    "hao-huiyu" => "Hao Huiyu",
    "haramura-nodoka" => "Haramura Nodoka",
    "hirose-sumire" => "Hirose Sumire",
    "ikeda-kana" => "Ikeda Kana",
    "inoue-jun" => "Inoue Jun",
    "iwadate-yuan" => "Iwadate Yuan",
    "iwato-kasumi" => "Iwato Kasumi",
    "jindai-komaki" => "Jindai Komaki",
    "kajiki-yumi" => "Kajiki Yumi",
    "kainou-yoshiko" => "Kainou Yoshiko",
    "kakura-kurumi" => "Kakura Kurumi",
    "kanbara-satomi" => "Kanbara Satomi",
    "karijuku-tomoe" => "Karijuku Tomoe",
    "kataoka-yuuki" => "Kataoka Yuuki",
    "kosegawa-shiromi" => "Kosegawa Shiromi",
    "kunihiro-hajime" => "Kunihiro Hajime",
    "mase-yuuko" => "Mase Yuuko",
    "matano-seiko" => "Matano Seiko",
    "matsumi-kuro" => "Matsumi Kuro",
    "matsumi-yuu" => "Matsumi Yuu",
    "maya-yukiko" => "Maya Yukiko",
    "megan-davin" => "Megan Davin",
    "miyanaga-saki" => "Miyanaga Saki",
    "miyanaga-teru" => "Miyanaga Teru",
    "motouchi-naruka" => "Motouchi Naruka",
    "nanpo-kazue" => "Nanpo Kazue",
    "nelly-virsaladze" => "Nelly Virsaladze",
    "onjouji-toki" => "Onjouji Toki",
    "oohoshi-awai" => "Oohoshi Awai",
    "ryuumonbuchi-touka" => "Ryuumonbuchi Touka",
    "sagimori-arata" => "Sagimori Arata",
    "sawamura-tomoki" => "Sawamura Tomoki",
    "senoo-kaori" => "Senoo Kaori",
    "shibuya-takami" => "Shibuya Takami",
    "shimizudani-ryuuka" => "Shimizudani Ryuuka",
    "shirouzu-mairu" => "Shirouzu Mairu",
    "shishihara-sawaya" => "Shishihara Sawaya",
    "someya-mako" => "Someya Mako",
    "suehara-kyouko" => "Suehara Kyouko",
    "takakamo-shizuno" => "Takakamo Shizuno",
    "takei-hisa" => "Takei Hisa",
    "takimi-haru" => "Takimi Haru",
    "toyouko-momoko" => "Toyouko Momoko",
    "tsujigaito-satoha" => "Tsujigaito Satoha",
    "tsuruta-himeko" => "Tsuruta Himeko",
    "ueshige-suzu" => "Ueshige Suzu",
    "usuzawa-sae" => "Usuzawa Sae",
    "usuzumi-hatsumi" => "Usuzumi Hatsumi",
    "yae-kobashiri" => "Yae Kobashiri",
    "yoshitome-miharu" => "Yoshitome Miharu",
    "yumeno-maho" => "Yumeno Maho",
  }

  def initialize_saki(state) do
    state = if not Rules.has_key?(state.rules_ref, "saki_ver") do
      show_error(state, """
      Expected rules file to have key \"saki_ver\".

      Supported versions: "v12", "v13"
      """)
    else state end
    
    state = if not Rules.has_key?(state.rules_ref, "saki_deck") do
      show_error(state, """
      Expected rules file to have key \"saki_deck\".

      This should be an array of supported saki cards. Example:

        \"saki_deck\": ["amae-koromo", "miyanaga-saki"]
      """)
    else state end
    
    state = Map.put(state, :saki, %{
      version: Rules.get(state.rules_ref, "saki_ver"),
      saki_deck: Enum.shuffle(Rules.get(state.rules_ref, "saki_deck")),
      saki_deck_index: 0,
    })

    state
  end

  def draw_saki_cards(state, num) do
    debug_card = Debug.debug_saki_card_ours()
    state = if debug_card != nil do
      update_in(state.saki.saki_deck, fn deck -> List.replace_at(deck, 3, debug_card) end)
    else state end

    debug_card_2 = Debug.debug_saki_card_opponent()
    state = if debug_card_2 != nil do
      state = update_in(state.saki.saki_deck, fn deck -> List.replace_at(deck, 4, debug_card_2) end)
      state = update_in(state.saki.saki_deck, fn deck -> List.replace_at(deck, 5, debug_card_2) end)
      state = update_in(state.saki.saki_deck, fn deck -> List.replace_at(deck, 6, debug_card_2) end)
      update_in(state.saki.saki_deck, fn deck -> List.replace_at(deck, 7, debug_card_2) end)
    else state end

    ix = state.saki.saki_deck_index
    cards = Enum.slice(state.saki.saki_deck, ix..ix+num-1)
    state = Map.update!(state, :saki, &Map.put(&1, :saki_deck_index, ix + num))
    {state, cards}
  end

  def saki_start(state) do
    state = if Rules.has_key?(state.rules_ref, "after_saki_start") do
      for {seat, _player} <- state.players, reduce: state do
        state ->
          choices = Enum.map(state.players[seat].status, &@card_names[&1])
          |> Enum.reject(& &1 == nil)
          |> Enum.join(", ")
          push_message(state, player_prefix(state, seat) ++ [
            %{text: "chose the following cards: %{choices}", vars: %{choices: {:text, choices, %{bold: true}}}}
          ])
          Actions.trigger_event(state, "after_saki_start", %{seat: seat})
      end
    else state end

    state = Buttons.recalculate_buttons(state, 0)
    notify_ai(state)
    state
  end

  def draft_saki_card(state, seat, choice) do
    update_player(state, seat, &%Player{ &1 | status: MapSet.put(&1.status, choice), call_buttons: %{} })
  end

  def check_if_all_drafted(state) do
    Enum.all?(state.players, fn {_seat, player} -> Enum.any?(player.status, &is_saki_card?/1) end)
  end
  
  def filter_cards(statuses) do
    Enum.filter(statuses, &is_saki_card?/1)
  end

  def is_saki_card?(status) do
    Map.has_key?(@card_names, status) or is_disabled_saki_card?(status)
  end

  def is_disabled_saki_card?(status) do
    if String.ends_with?(status, "-disabled") do
      new_status = String.slice(status, 0..-10//1)
      Map.has_key?(@card_names, new_status)
    else false end
  end

  def disable_saki_card(state, targets) do
    for seat <- targets, reduce: state do
      state ->
        update_in(state.players[seat].status, &MapSet.new(&1, fn status ->
          if Map.has_key?(@card_names, status) do
            status <> "-disabled"
          else status end
        end))
    end
  end

  def enable_saki_card(state, targets) do
    for seat <- targets, reduce: state do
      state ->
        update_in(state.players[seat].status, &MapSet.new(&1, fn status ->
          if is_disabled_saki_card?(status) do
            String.slice(status, 0..-10//1)
          else status end
        end))
    end
  end
end