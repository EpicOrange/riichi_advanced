defmodule RiichiAdvancedWeb.YakuSelectionComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    # for some reason, any liveview update disappears the first <form> in this component
    # so we add an empty <form></form> at the top, which gets disappeared (no visual effect)
    # no idea what the root cause for this phenomenon is
    ~H"""
    <div class={["yaku-selection", "yaku-#{@ruleset}"]}>
      <form></form>
      <div class="yaku-selection-inner-container">
        <%= for {list_name, yakus} <- @yaku |> Enum.group_by(& &1.list_name) |> Enum.sort_by(fn {list_name, _yaku} -> Enum.find_index(@yaku_list_names, & &1 == list_name) end) do %>
          <div class="yaku-list-name" :if={list_name}><%= list_name %></div>
          <div class="yaku-list-spacer"></div>
          <%= for %{name: yaku_name, value: value, selected: selected, index: index} <- yakus do %>
            <input id={"#{@ruleset}-#{yaku_name}-#{index}"} name={"#{@ruleset}-#{yaku_name}-#{index}"} type="checkbox" phx-click="toggle_yaku" phx-value-index={index} phx-value-selected={if selected do "true" else "false" end} checked={selected}>
            <label for={"#{@ruleset}-#{yaku_name}-#{index}"} data-name={dt(@lang, yaku_name)} tabindex={index} class="yaku-button">
              <%= dt(@lang, yaku_name) %>
              (
              <form phx-change="change_yaku_value" phx-value-index={index}>
                <input name="yaku-value" type="number" value={value} onclick="this.select();" style={"--width: #{if is_number(value) do Integer.to_string(value) else value end |> String.length()};"}>
              </form>
              )
            </label>
          <% end %>
          <div class="yaku-list-spacer"></div>
        <% end %>
      </div>
    </div>
    """
  end
end
