defmodule RiichiAdvancedWeb.Seo do
  use Xeo, warn: false, pad: 4

  seo "/" do
    description "Infinitely extensible mahjong web client -- play Riichi, Hong Kong Old Style, Taiwanese, Sichuan Bloody, Space Mahjong, MCR, and more"

    og_type "website"
    og_title "Riichi Advanced"
    og_image "/images/title.png"
    og_site_name "riichiadvanced.com"
    og_description "Infinitely extensible mahjong web client."
  end

end