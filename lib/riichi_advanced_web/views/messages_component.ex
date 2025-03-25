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
    <div class="messages-container">
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
              case Map.get(vars, String.to_existing_atom(var_name)) do
                {:tile, tile} ->
                  acc = acc ++ [Map.merge(message, %{text: current, vars: current_vars})] ++ [Utils.pt(tile)]
                  {acc, "", %{}}
                {:hand, hand} ->
                  acc = acc ++ [Map.merge(message, %{text: current, vars: current_vars})] ++ Utils.ph(hand)
                  {acc, "", %{}}
                val when is_binary(val) ->
                  current = current <> "%{#{var_name}}"
                  current_vars = Map.put(current_vars, String.to_existing_atom(var_name), val)
                  {acc, current, current_vars}
              end
            segment -> {acc, current <> segment, current_vars}
          end
        end
        messages ++ [Map.merge(message, %{text: current, vars: current_vars})]
        |> IO.inspect()
    end
  end
end

