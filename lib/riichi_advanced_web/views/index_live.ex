defmodule RiichiAdvancedWeb.IndexLive do
  alias RiichiAdvanced.Constants, as: Constants
  alias RiichiAdvanced.LobbyState, as: LobbyState
  alias RiichiAdvanced.LobbyState.Lobby, as: Lobby
  alias RiichiAdvanced.Utils, as: Utils
  use RiichiAdvancedWeb, :live_view

  def mount(_params, session, socket) do
    socket = socket
    |> assign(:session_id, session["session_id"])
    |> assign(:messages, [])
    |> assign(:show_room_code_buttons, false)
    |> assign(:room_code, [])
    |> assign(:version, Constants.version())
    messages_init = RiichiAdvanced.MessagesState.init_socket(socket)
    socket = if Map.has_key?(messages_init, :messages_state) do
      socket = assign(socket, :messages_state, messages_init.messages_state)
      # subscribe to message updates
      Phoenix.PubSub.subscribe(RiichiAdvanced.PubSub, "messages:" <> socket.id)
      GenServer.cast(messages_init.messages_state, {:add_message, %{text: "Welcome to Riichi Advanced!"}})
      socket
    else socket end
    socket = assign(socket, :rulesets, [
      {"riichi",       "Riichi", "The classic riichi ruleset, now with an assortment of mods to pick and choose at your liking."},
      {"sanma",        "Sanma", "Three-player Riichi."},
      {"space",        "Space Mahjong", "Riichi, but sequences can wrap (891, 912), and you can make sequences from winds and dragons. In addition, you can chii from any direction, and form open kokushi (3 han)."},
      {"cosmic",       "Cosmic Riichi", "A Space Mahjong variant with mixed triplets, more yaku, and more calls."},
      {"galaxy",       "Galaxy Mahjong", "Riichi, but one of each tile is replaced with a blue galaxy tile that acts as a wildcard of its number. Galaxy winds are wind wildcards, and galaxy dragons are dragon wildcards."},
      {"kansai",       "Kansai Sanma", "Sanma, but you draw until the last visible dora indicator. In addition, all fives are akadora, fu is fixed at 30, there is no tsumo loss, and scores are rounded to the nearest 1000. Flowers act as nukidora in place of north winds, which are now yakuhai. Exhaustive draws in south round always result in a repeat regardless of who's tenpai."},
      {"chinitsu",     "Chinitsu", "Two-player variant where the only tiles are bamboo tiles. Try not to chombo!"},
      {"minefield",    "Minefield", "Two-player variant where you start with 34 tiles to make a mangan+ hand, and your remaining tiles are your discards."},
      {"saki",         "Sakicards v1.3", "Riichi, but everyone gets a different Saki power, which changes the game quite a bit. Some give you bonus han every time you use your power. Some let you recover dead discards. Some let you swap tiles around the entire board, including the dora indicator."},
      {"hk",           "Hong Kong", "Hong Kong Old Style mahjong. Three point minimum, everyone pays for a win, and win instantly if you have seven flowers."},
      {"sichuan",      "Sichuan Bloody", "Sichuan Bloody mahjong. Trade tiles, void a suit, and play until three players win (bloody end rules)."},
      {"mcr",          "MCR", "Mahjong Competition Rules. Has a scoring system of a different kind of complexity than Riichi."},
      {"taiwanese",    "Taiwanese", "16-tile mahjong with riichi mechanics."},
      {"bloody30faan", "Bloody 30-Faan Jokers", "Bloody end rules mahjong, with Vietnamese jokers, and somehow more yaku than MCR."},
      {"american",     "American (2024 NMJL)", "American mahjong. Assemble hands with jokers, and declare other players' hands dead. Rules are not available for this one."},
      {"vietnamese",   "Vietnamese", "Mahjong with eight differently powerful joker tiles."},
      {"malaysian",    "Malaysian", "Three-player mahjong with 16 flowers, a unique joker tile, and instant payouts."},
      {"singaporean",  "Singaporean", "Mahjong with various instant payouts and various unique ways to get penalized by pao."},
      {"custom",       "Custom", "Create and play your own custom ruleset."},
    ])
    socket = assign(socket, :unimplemented_rulesets, [
      {"fuzhou",       "Fuzhou", "16-tile mahjong with a version of dora that doesn't give you han, but becomes a unique winning condition by itself.", "https://old.reddit.com/r/Mahjong/comments/171izis/fuzhou_mahjong_rules_corrected/"},
      {"filipino",     "Filipino", "16-tile mahjong where all honor tiles are flower tiles.", "https://mahjongpros.com/blogs/mahjong-rules-and-scoring-tables/official-filipino-mahjong-rules"},
      {"visayan",      "Visayan", "16-tile mahjong where you can form dragon and wind sequences.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-filipino-visayan-mahjong"},
      {"tianjin",      "Tianjin", "Mahjong except the dora indicator actually indicates joker tiles.", "https://michaelxing.com/mahjong/instr.php"},
      {"ningbo",       "Ningbo", "Includes Tianjin mahjong joker tiles, but adds more yaku and played with a 4-tai minimum.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-ningbo-mahjong-rules"},
      {"hefei",        "Hefei", "Mahjong with no honor tiles, but you must have at least eight tiles of a single suit to win.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-hefei-mahjong"},
      {"changsha",     "Changsha", "Mahjong, but every win gets two chances at ura dora. However, a standard hand must have a pair of 22, 55, or 88.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-changsha-mahjong"},
      {"shenyang",     "Shenyang", "Mahjong, but every hand must be open, contain every suit, contain a terminal/honor, and contain either a triplet, kan, or dragon pair.", "https://peterish.com/riichi-docs/shenyang-mahjong-rules/"},
      {"korean",       "Korean", "Like Riichi but with a two-han minimum. There is also a side race to see who reaches three wins first.", "https://mahjongpros.com/blogs/mahjong-rules-and-scoring-tables/official-korean-mahjong-rules"},
      {"cn_classical", "Chinese Classical", "Mahjong but every pung and kong gives you points, and every hand pattern doubles your points.", "http://mahjong.wikidot.com/rules:chinese-classical-scoring"},
      {"zung_jung",    "Zung Jung", "Mahjong with an additive (rather than multiplicative) scoring system.", "https://www.zj-mahjong.info/zj33_rules_eng.html"},
      {"british",      "British", "No description provided.", "https://wonderfuloldthings.wordpress.com/wp-content/uploads/2013/09/british-rules-guide-to-mahjong-v2-1.pdf"},
      {"italian",      "Italian", "No description provided.", "https://www.fimj.it/wp-content/uploads/2012/01/111213_Regolamento_FIMJ_A4.pdf"},
      {"dutch",        "Dutch", "No description provided.", "https://mahjongbond.org/wp-content/uploads/2019/10/NMB-NTS-Spelregelboekje.pdf"},
      {"german",       "German", "No description provided.", "https://www-user.tu-chemnitz.de/~sontag/mahjongg/"},
      {"french",       "French", "No description provided.", "https://web.archive.org/web/20050203025449/http://mahjongg.free.fr/Regles.php3"},
      {"australian",   "Australian", "No description provided.", "https://balsallcommonu3a.org/Downloads/Mahjong%20Rules%20November%202016.pdf"},
    ])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id="container" phx-hook="ClickListener">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <input type="checkbox" id="expand-checkbox" class="expand-checkbox for-rulesets" phx-update="ignore"/>
      <label for="expand-checkbox"/>
      <form phx-submit="redirect">
        <div class="ruleset-selection">
          <%= for {{ruleset, name, desc}, i} <- Enum.with_index(@rulesets) do %>
            <input type="radio" id={ruleset} name="ruleset" value={ruleset} checked={i==0} phx-update="ignore">
            <label for={ruleset} title={desc}><%= name %></label>
          <% end %>
          <br/>
          To be implemented:
          <%= for {ruleset, name, desc, link} <- @unimplemented_rulesets do %>
            <input type="radio" id={ruleset} name="ruleset" value={ruleset} disabled>
            <label for={ruleset} title={desc}><a href={link} target="_blank"><%= name %></a></label>
          <% end %>
        </div>
        <input class="nickname-input" type="text" name="nickname" placeholder="Nickname (optional)" />
        <div class="enter-buttons">
          <button name="play" type="submit">Play</button>
          <button name="learn" type="submit">Learn</button>
          <button type="button" phx-cancellable-click="toggle_show_room_code">
            <%= if @show_room_code_buttons do %>
              Close
            <% else %>
              Join private room
            <% end %>
          </button>
        </div>
      </form>
      <%= if @show_room_code_buttons do %>
        <.live_component module={RiichiAdvancedWeb.RoomCodeComponent} id="room-code" set_room_code={&send(self(), {:set_room_code, &1})} />
      <% end %>
      <div class="index-version"><%= @version %></div>
      <div class="index-bottom-buttons">
        <button phx-click="goto_about">About</button>
        <button><a href="https://github.com/EpicOrange/riichi_advanced" target="_blank">Source</a></button>
        <button><a href="https://discord.gg/5QQHmZQavP" target="_blank">Discord</a></button>
        <button phx-click="goto_logs">Logs</button>
      </div>
      <.live_component module={RiichiAdvancedWeb.MessagesComponent} id="messages" messages={@messages} />
    </div>
    """
  end

  def handle_event("double_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("right_clicked", _assigns, socket) do
    {:noreply, socket}
  end

  def handle_event("toggle_show_room_code", _assigns, socket) do
    socket = assign(socket, :show_room_code_buttons, not socket.assigns.show_room_code_buttons)
    {:noreply, socket}
  end

  def handle_event("redirect", params, socket) do
    %{"ruleset" => ruleset, "nickname" => nickname} = params
    if Map.has_key?(params, "play") do
      if socket.assigns.show_room_code_buttons do
        socket = if length(socket.assigns.room_code) == 3 do
          # enter private room, or create a new room
          room_code = Enum.join(socket.assigns.room_code, ",")
          push_navigate(socket, to: ~p"/room/#{ruleset}/#{room_code}?nickname=#{nickname}")
        else socket end
        {:noreply, socket}
      else
        # get all running session ids for this ruleset
        room_codes = DynamicSupervisor.which_children(RiichiAdvanced.RoomSessionSupervisor)
        |> Enum.flat_map(fn {_, pid, _, _} -> Registry.keys(:game_registry, pid) end)
        |> Enum.filter(fn name -> String.starts_with?(name, "room-#{ruleset}-") end)
        |> Enum.map(fn name -> String.replace_prefix(name, "room-#{ruleset}-", "") end)
        # check if there are any public rooms of this ruleset
        # if not, skip the lobby and go directly to making a new table
        has_public_room = Enum.any?(room_codes, fn room_code -> 
          [{room_state_pid, _}] = Registry.lookup(:game_registry, Utils.to_registry_name("room_state", ruleset, room_code))
          room_state = GenServer.call(room_state_pid, :get_state)
          not room_state.private
        end)
        socket = if has_public_room do
          push_navigate(socket, to: ~p"/lobby/#{ruleset}?nickname=#{nickname}")
        else
          {:ok, _, room_code} = LobbyState.create_room(%Lobby{ruleset: ruleset})
          push_navigate(socket, to: ~p"/room/#{ruleset}/#{room_code}?nickname=#{nickname}")
        end
        {:noreply, socket}
      end
    else
      # tutorial
      socket = if ruleset != "custom" do
        push_navigate(socket, to: ~p"/tutorial/#{ruleset}?nickname=#{nickname}")
      else socket end
      {:noreply, socket}
    end
  end
  
  def handle_event("goto_about", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/about")
    {:noreply, socket}
  end
  
  def handle_event("goto_logs", _assigns, socket) do
    socket = push_navigate(socket, to: ~p"/log")
    {:noreply, socket}
  end

  def handle_info(%{topic: topic, event: "messages_updated", payload: %{"state" => state}}, socket) do
    if topic == "messages:" <> socket.id do
      socket = assign(socket, :messages, state.messages)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:set_room_code, room_code}, socket) do
    socket = assign(socket, :room_code, room_code)
    {:noreply, socket}
  end

end
