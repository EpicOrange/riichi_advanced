defmodule RiichiAdvancedWeb.Seo do
  use Xeo, warn: false, pad: 4

  @title "Riichi Advanced"
  @description "Infinitely extensible mahjong web client -- play Riichi, Hong Kong Old Style, Taiwanese, Sichuan Bloody, Space Mahjong, MCR, and more"
  @url "https://riichiadvanced.com"
  @image "/images/title.png"

  seo "/" do
    title @title
    description @description
    canonical @url

    og_type "website"
    og_title "Riichi Advanced"
    og_site_name @title
    og_description @description
    og_url @url
    og_image @image

    twitter_card "summary_large_image"
    twitter_title @title
    twitter_description @description
    twitter_url @url
    twitter_image @image
  end

end