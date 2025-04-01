defmodule RiichiAdvancedWeb.MessagesComponent do
  alias RiichiAdvanced.Utils
  use RiichiAdvancedWeb, :live_component
  use Gettext, backend: RiichiAdvancedWeb.Gettext
  import RiichiAdvancedWeb.Translations

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="messages-container" phx-click="noop" phx-target={@myself}>
      <div class="messages">
        <%= for msg <- @messages do %>
          <span>
            <%= for m <- List.wrap(msg) |> Enum.flat_map(&preprocess(&1, @lang)) do %>
              <span style={"color: #{Map.get(m, :color, "white")};"} class={[Map.get(m, :bold, false) && "bold"]}>
                <%= dt(@lang, m.text, Map.get(m, :vars, %{})) %>
              </span>
            <% end %>
          </span>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("noop", _assigns, socket), do: {:noreply, socket}

  def preprocess(message, lang) do
    # convert
    # %{text: "called %{call} on %{tile} with hand %{hand}", vars: %{call: "pon", tile: {:tile, :"7m"}, hand: {:hand, [:"8m", :"9m"]}}
    # to
    # [%{text: "called %{call} on", vars: %{call: "pon"}}]
    # ++ Utils.pt(tile)
    # ++ [%{text: "with hand"}]
    # ++ Utils.ph(hand)
    case Map.get(message, :vars) do
      nil  -> [message]
      vars ->
        segments = Regex.split(~r/%{(\w+)}/, dt(lang, message.text), include_captures: true, trim: true)
        {messages, current, current_vars} = for segment <- segments, reduce: {[], "", %{}} do
          {acc, current, current_vars} ->
          case segment do
            <<"%{" <> rest>> ->
              var_name = String.trim_trailing(rest, "}")
              case Map.get(vars, String.to_existing_atom(var_name)) || Map.get(vars, var_name) do
                {:tile, tile} ->
                  acc = acc ++ [Map.merge(message, %{text: current, vars: current_vars})] ++ [Utils.pt(tile)]
                  {acc, "", %{}}
                {:hand, hand} ->
                  acc = acc ++ [Map.merge(message, %{text: current, vars: current_vars})] ++ Utils.ph(hand)
                  {acc, "", %{}}
                {:text, text, attrs} ->
                  acc = acc ++ [Map.merge(message, %{text: current, vars: current_vars}), Map.put(attrs, :text, text)]
                  {acc, "", %{}}
                nil ->
                  IO.puts("WARNING: tried to reference gettext interpolation variable #{var_name} but it was not provided")
                  {acc, current, current_vars}
                val ->
                  current = current <> "%{#{var_name}}"
                  current_vars = Map.put(current_vars, String.to_existing_atom(var_name), to_string(val))
                  {acc, current, current_vars}
              end
            segment -> {acc, current <> segment, current_vars}
          end
        end
        messages ++ [Map.merge(message, %{text: current, vars: current_vars})]
    end
  end
end

