defmodule RiichiAdvanced.Cache do
  use Nebulex.Cache,
    otp_app: :riichi_advanced,
    adapter: Nebulex.Adapters.Local
end
