defmodule Mix.Tasks.GenerateGettextHints do
  use Mix.Task
  @impl Mix.Task
  def run(_args) do
    rulesets = for {_key, name, desc} <- RiichiAdvanced.Constants.available_rulesets(), do: [name, desc]
    tutorials = for {_k, vs} <- RiichiAdvanced.Constants.tutorials(), {_, name, _} <- vs, do: [name]
    ai_names = RiichiAdvanced.Constants.ai_names()
    tips = RiichiAdvancedWeb.TipsComponent.tips()
    tutorial_text = for path <- Path.wildcard("priv/static/tutorials/*.json") do
      sequence = path |> File.read!() |> RiichiAdvanced.ModLoader.strip_comments() |> Jason.decode!()
      for {_scene, actions} <- sequence["scenes"],
          ["add_object", "text", %{"text" => text}] <- actions,
          line <- String.split(text, "\n", trim: true), do: line
    end
    out = List.flatten([rulesets, tutorials, ai_names, tutorial_text, tips]) |> Enum.join("\n")
    File.write!("priv/gettext/strings.txt", out <> "\n")
  end
end
