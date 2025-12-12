defmodule RiichiAdvancedWeb.ModSelectionComponent do
  use RiichiAdvancedWeb, :live_component
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    socket = assign(socket, :length, 2)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={["mods", "mods-#{@ruleset}"]}>
      <div class="mods-inner-container">
        <%= for {category, mods} <- Enum.group_by(@mods, fn {_name, mod} -> mod.category end) |> Enum.sort_by(fn {category, _mods} -> Enum.find_index(@categories, & &1 == category) end) do %>
          <div class="mod-category" :if={category}>
            <%= dt(@lang, category) %>
            <button class="mod-menu-button" phx-cancellable-click="toggle_category" phx-value-category={category}><%= t(@lang, "Toggle all") %></button>
          </div>
          <%= for {mod_id, mod} <- Enum.sort_by(mods, fn {_mod_name, mod} -> mod.index end) do %>
            <input id={mod_id} type="checkbox" phx-click="toggle_mod" phx-value-mod={mod_id} phx-value-enabled={if @mods[mod_id].enabled do "true" else "false" end} checked={@mods[mod_id].enabled}>
            <label for={mod_id} title={dt(@lang, mod.desc)} data-name={dt(@lang, mod.name)} tabindex={mod.index} class={["mod", mod.class]}>
              <%= dt(@lang, mod.name) %>
              <%= if mod.enabled and not Enum.empty?(mod.config) do %>
                |
                <%= for {config_name, config} <- mod.config do %>
                  <span class="mod-config-name"><%= dt(@lang, String.replace_prefix(config_name, "_", "")) %>:</span>
                  <%= case config["type"] do %>
                    <% "dropdown" -> %>
                      <form class="mod-config-dropdown" phx-change="change_mod_config" phx-value-mod={mod_id} phx-value-name={config_name}>
                        <select name={config_name}>
                          <%= for {value, i} <- Enum.with_index(config["values"]) do %>
                            <%= if value == config.value do %>
                              <option value={i} selected><%= dt(@lang, to_string(value)) %></option>
                            <% else %>
                              <option value={i}><%= dt(@lang, to_string(value)) %></option>
                            <% end %>
                          <% end %>
                        </select>
                      </form>
                    <% "slider" -> %>
                      <form class="mod-config-slider" phx-change="change_mod_config" phx-value-mod={mod_id} phx-value-name={config_name}>
                        <input type="range" name={config_name} list={"#{mod_id}-#{config_name}-list"} min="0" max={length(config["values"])-1}>
                        <datalist id={"#{mod_id}-#{config_name}-list"}>
                          <option value={i} :for={{value, i} <- Enum.with_index(config["values"])}><%= value %></option>
                        </datalist>
                      </form>
                    <% _ -> %>
                  <% end %>
                <% end %>
              <% end %>
            </label>
          <% end %>
          <div class="mod-category-spacer"></div>
        <% end %>
        <div class="mods-bottom-buttons">
          <button class="mod-menu-button" phx-cancellable-click="reset_mods_to_default"><%= t(@lang, "Reset mods to default") %></button>
          <button class="mod-menu-button" phx-cancellable-click="randomize_mods"><%= t(@lang, "Randomize mods") %></button>
        </div>
      </div>
    </div>
    """
  end
end
