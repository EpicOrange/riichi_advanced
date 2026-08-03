defmodule Mix.Tasks.GenerateGettextHints do
  use Mix.Task
  @impl Mix.Task
  def run(_args) do
    rulesets = for {_key, name, desc} <- RiichiAdvanced.Constants.available_rulesets(), do: [name, desc]
    tutorials = for {_k, vs} <- RiichiAdvanced.Constants.tutorials(), {_, name, _} <- vs, do: [name]
    ai_names = RiichiAdvanced.Constants.ai_names()
    tips = RiichiAdvancedWeb.TipsComponent.tips()
    out = List.flatten([rulesets, tutorials, ai_names, tips]) |> Enum.join("\n")
    File.write!("priv/gettext/strings.txt", out)
  end
end
