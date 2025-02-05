defmodule RiichiAdvanced.Constants do

  @version "v1.0.2." <> (System.cmd("git", ["rev-parse", "--short", "HEAD"]) |> elem(0) |> String.trim())

  def version, do: @version
end