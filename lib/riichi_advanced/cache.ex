# clear with:
# RiichiAdvanced.Cache.delete_all()
defmodule RiichiAdvanced.Cache do
  use Nebulex.Cache,
    otp_app: :riichi_advanced,
    adapter: Nebulex.Adapters.Local,
    gc_interval: :timer.seconds(10)
end
