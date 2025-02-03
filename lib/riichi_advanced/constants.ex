defmodule RiichiAdvanced.Constants do

  @version "v1.0.1." <> (System.cmd("git", ["rev-parse", "--short", "HEAD"]) |> elem(0) |> String.trim())

  def version, do: @version
end