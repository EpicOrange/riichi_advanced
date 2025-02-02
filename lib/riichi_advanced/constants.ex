defmodule RiichiAdvanced.Constants do

  @version "v1.0.0." <> (System.cmd("git", ["rev-parse", "--short", "HEAD"]) |> elem(0) |> String.trim())

  def version, do: @version
end