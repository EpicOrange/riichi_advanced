# clear with:
# RiichiAdvanced.Cache.delete_all()

# this one is for everything basically
defmodule RiichiAdvanced.Cache do
  use Nebulex.Cache,
    otp_app: :riichi_advanced,
    adapter: Nebulex.Adapters.Local
end

# this one is for function memoization via @decorate cacheable
defmodule RiichiAdvanced.Cache.Memo do
  use Nebulex.Cache,
    otp_app: :riichi_advanced,
    adapter: Nebulex.Adapters.Local
end
