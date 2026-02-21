defmodule RiichiAdvancedWeb.YakuSelectionComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["yaku-container", "yaku-#{@ruleset}"]}>
      <div class="yaku-inner-container">
        <%= for {list_name, yakus} <- @yaku |> Enum.group_by(& &1.list_name) |> Enum.sort_by(fn {list_name, _yaku} -> Enum.find_index(@yaku_list_names, & &1 == list_name) end) do %>
          <div class="yaku-list-name" :if={list_name}><%= list_name %></div>
          <div class="yaku-list-spacer"></div>
          <%= for %{name: yaku_name, desc: desc, value: value, value_name: value_name, selected: selected, index: index} <- yakus do %>
            <input id={"#{@ruleset}-#{yaku_name}-#{index}"} name={"#{@ruleset}-#{yaku_name}-#{index}"} type="checkbox" phx-click="toggle_yaku" phx-value-index={index} phx-value-selected={if selected do "true" else "false" end} checked={selected}>
            <label for={"#{@ruleset}-#{yaku_name}-#{index}"} title={dt(@lang, desc)} data-name={dt(@lang, yaku_name)} tabindex={index} class="yaku-button">
              <%= dt(@lang, yaku_name) %>
              (
              <form phx-change="change_yaku_value" phx-value-index={index}>
                <input name="yaku-value" type="number" value={print_value(value)} onclick="this.select();" style={"--width: #{print_value(value) |> String.length()};"}>
              </form>
              <%= dt(@lang, value_name) %>
              )
            </label>
          <% end %>
          <div class="yaku-list-spacer"></div>
        <% end %>
      </div>
    </div>
    """
  end

  def print_value(value) do
    cond do
      is_number(value) -> Integer.to_string(value)
      is_list(value) -> Enum.at(value, 0) |> Integer.to_string()
      is_binary(value) -> "0"
      true -> value
    end
  end

end
