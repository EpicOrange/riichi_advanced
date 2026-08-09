defmodule RiichiAdvancedWeb.RulesPopoverComponent do
  use RiichiAdvancedWeb, :live_component
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    socket = assign(socket, :rules_text, %{})
    socket = assign(socket, :rules_text_order, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="rules-wrapper">
      <%= for rules_text_name <- @rules_text_order, not Enum.empty?(@rules_text[rules_text_name]) do %>
        <% rules_id = "rules-popover-radio-#{String.replace(rules_text_name, " ", "-")}" %>
        <input type="radio" id={rules_id} name="rules-popover-tab" class="rules-popover-radio" phx-update="ignore">
        <label for={rules_id} class={"lang-#{@lang}"}><%= dt(@lang, rules_text_name) %></label>
        <div class="rules-popover-container" phx-click="noop">
          <div class="rules-popover">
            <%= for {title, {text, vars, priority}} <- Enum.sort_by(@rules_text[rules_text_name], fn {_title, {text, _vars, priority}} -> {priority, text |> Enum.join("\n") |> String.length()} end) do %>
              <div class={["rules-popover-rule", priority < 0 && "full-width"]}>
                <div class="rules-popover-title"><%= dt(@lang, title, vars) %></div>
                <div class="rules-popover-text"><%= raw Enum.map_join(text, "\n", &dt(@lang, &1, vars)) %></div>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
      <input type="radio" id={"rules-popover-unselect"} name="rules-popover-tab" class="rules-popover-unselect" phx-update="ignore">
      <label for={"rules-popover-unselect"}></label>
    </div>
    """
  end
end
