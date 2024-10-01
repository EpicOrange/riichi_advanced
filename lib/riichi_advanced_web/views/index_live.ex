defmodule RiichiAdvancedWeb.IndexLive do
  use RiichiAdvancedWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="main-page">
      <div class="title">
        <div class="title-riichi">Riichi</div>
        <div class="title-advanced">Advanced</div>
        <div class="tile 8m"></div>
        <div class="tile 7z"></div>
      </div>
      <form phx-submit="redirect">
        Ruleset:
        <select name="ruleset" id="ruleset">
          <option value="riichi" selected>Riichi</option>
          <option value="hk">Hong Kong</option>
          <option value="sichuan">Sichuan Bloody</option>
          <option value="saki">Sakijong v1.2</option>
          <option value="vietnamese">Vietnamese</option>
          <option value="bloody30faan">Bloody 30-Faan (beta)</option>
        </select>
        <br/>
        Room:
        <input type="text" name="session_id" placeholder="Room ID (required)" value="main" />
        <br/>
        Name:
        <input type="text" name="nickname" placeholder="Nickname (optional)" />
        <br/>
        <button type="submit" class="enter-button">Enter</button>
      </form>
    </div>
    """
  end

  def handle_event("redirect", %{"ruleset" => ruleset, "session_id" => session_id, "nickname" => nickname}, socket) do
    socket = if session_id != "" do
      running_games = Registry.lookup(:game_registry, Utils.to_registry_name("game_state", ruleset, session_id))
      if Enum.empty?(running_games) do
        push_navigate(socket, to: ~p"/lobby/#{ruleset}/#{session_id}?nickname=#{nickname}")
      else
        push_navigate(socket, to: ~p"/game/#{ruleset}/#{session_id}?nickname=#{nickname}")
      end
    else socket end
    {:noreply, socket}
  end
end
