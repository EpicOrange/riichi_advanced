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
      all_drafted: false
    })

    state
  end

  def draft_saki_cards(state, num) do
    ix = state.saki.saki_deck_index
    cards = Enum.slice(state.saki.saki_deck, ix..ix+num-1)
    state = Map.update!(state, :saki, &Map.put(&1, :saki_deck_index, ix + num))
    {state, cards}
  end

  def check_if_all_drafted(state) do
    all_drafted = Enum.all?(state.players, fn {seat, player} ->
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
end