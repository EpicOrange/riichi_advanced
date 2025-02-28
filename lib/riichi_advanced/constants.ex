defmodule RiichiAdvanced.Constants do
  alias RiichiAdvanced.Utils, as: Utils

  @version "v1.1.1." <> (System.cmd("git", ["rev-parse", "--short", "HEAD"]) |> elem(0) |> String.trim())

  def version, do: @version

  @to_tile %{"1m"=>:"1m", "2m"=>:"2m", "3m"=>:"3m", "4m"=>:"4m", "5m"=>:"5m", "6m"=>:"6m", "7m"=>:"7m", "8m"=>:"8m", "9m"=>:"9m", "10m"=>:"10m", "0m"=>:"0m",
             "1p"=>:"1p", "2p"=>:"2p", "3p"=>:"3p", "4p"=>:"4p", "5p"=>:"5p", "6p"=>:"6p", "7p"=>:"7p", "8p"=>:"8p", "9p"=>:"9p", "10p"=>:"10p", "0p"=>:"0p",
             "1s"=>:"1s", "2s"=>:"2s", "3s"=>:"3s", "4s"=>:"4s", "5s"=>:"5s", "6s"=>:"6s", "7s"=>:"7s", "8s"=>:"8s", "9s"=>:"9s", "10s"=>:"10s", "0s"=>:"0s", "00s"=>:"00s",
             "1t"=>:"1t", "2t"=>:"2t", "3t"=>:"3t", "4t"=>:"4t", "5t"=>:"5t", "6t"=>:"6t", "7t"=>:"7t", "8t"=>:"8t", "9t"=>:"9t", "10t"=>:"10t", "0t"=>:"0t",
             "1z"=>:"1z", "2z"=>:"2z", "3z"=>:"3z", "4z"=>:"4z", "5z"=>:"5z", "6z"=>:"6z", "7z"=>:"7z", "8z"=>:"8z", "9z"=>:"9z", "0z"=>:"0z",
             "1x"=>:"1x", "2x"=>:"2x", "3x"=>:"3x", "4x"=>:"4x", "5x"=>:"5x", "6x"=>:"6x", "7x"=>:"7x", "8x"=>:"8x",
             "1f"=>:"1f", "2f"=>:"2f", "3f"=>:"3f", "4f"=>:"4f",
             "1g"=>:"1g", "2g"=>:"2g", "3g"=>:"3g", "4g"=>:"4g",
             "1a"=>:"1a", "2a"=>:"2a", "3a"=>:"3a", "4a"=>:"4a",
             "1k"=>:"1k", "2k"=>:"2k", "3k"=>:"3k", "4k"=>:"4k",
             "1q"=>:"1q", "2q"=>:"2q", "3q"=>:"3q", "4q"=>:"4q",
             "1y"=>:"1y", "2y"=>:"2y",
             "0j"=>:"0j", "1j"=>:"1j", "2j"=>:"2j", "3j"=>:"3j", "4j"=>:"4j", "5j"=>:"5j", "6j"=>:"6j", "7j"=>:"7j", "8j"=>:"8j", "9j"=>:"9j",
             "10j"=>:"10j", "12j"=>:"12j", "13j"=>:"13j", "14j"=>:"14j", "15j"=>:"15j", "16j"=>:"16j", "17j"=>:"17j", "18j"=>:"18j",
             "19j"=>:"19j", "37j"=>:"37j", "46j"=>:"46j", "147j"=>:"147j", "258j"=>:"258j", "369j"=>:"369j", "123j"=>:"123j", "456j"=>:"456j", "789j"=>:"789j",
             "91j"=>:"91j", "73j"=>:"73j", "64j"=>:"64j", "852j"=>:"852j", "20j"=>:"20j", "11j"=>:"11j", "22j"=>:"22j",
             "30j"=>:"30j", "31j"=>:"31j", "32j"=>:"32j", "33j"=>:"33j", "34j"=>:"34j",
             "11m"=>:"11m", "12m"=>:"12m", "13m"=>:"13m", "14m"=>:"14m", "15m"=>:"15m", "16m"=>:"16m", "17m"=>:"17m", "18m"=>:"18m", "19m"=>:"19m", "110m"=>:"110m",
             "11p"=>:"11p", "12p"=>:"12p", "13p"=>:"13p", "14p"=>:"14p", "15p"=>:"15p", "16p"=>:"16p", "17p"=>:"17p", "18p"=>:"18p", "19p"=>:"19p", "110p"=>:"110p",
             "11s"=>:"11s", "12s"=>:"12s", "13s"=>:"13s", "14s"=>:"14s", "15s"=>:"15s", "16s"=>:"16s", "17s"=>:"17s", "18s"=>:"18s", "19s"=>:"19s", "110s"=>:"110s", "100s"=>:"100s",
             "11t"=>:"11t", "12t"=>:"12t", "13t"=>:"13t", "14t"=>:"14t", "15t"=>:"15t", "16t"=>:"16t", "17t"=>:"17t", "18t"=>:"18t", "19t"=>:"19t", "110t"=>:"110t",
             "11z"=>:"11z", "12z"=>:"12z", "13z"=>:"13z", "14z"=>:"14z", "15z"=>:"15z", "16z"=>:"16z", "17z"=>:"17z", "18z"=>:"18z",
             "01m"=>:"01m", "02m"=>:"02m", "03m"=>:"03m", "04m"=>:"04m", "05m"=>:"05m", "06m"=>:"06m", "07m"=>:"07m", "08m"=>:"08m", "09m"=>:"09m", "010m"=>:"010m",
             "01p"=>:"01p", "02p"=>:"02p", "03p"=>:"03p", "04p"=>:"04p", "05p"=>:"05p", "06p"=>:"06p", "07p"=>:"07p", "08p"=>:"08p", "09p"=>:"09p", "010p"=>:"010p",
             "01s"=>:"01s", "02s"=>:"02s", "03s"=>:"03s", "04s"=>:"04s", "05s"=>:"05s", "06s"=>:"06s", "07s"=>:"07s", "08s"=>:"08s", "09s"=>:"09s", "010s"=>:"010s", "000s"=>:"000s",
             "01t"=>:"01t", "02t"=>:"02t", "03t"=>:"03t", "04t"=>:"04t", "05t"=>:"05t", "06t"=>:"06t", "07t"=>:"07t", "08t"=>:"08t", "09t"=>:"09t", "010t"=>:"010t",
             "01z"=>:"01z", "02z"=>:"02z", "03z"=>:"03z", "04z"=>:"04z", "05z"=>:"05z", "06z"=>:"06z", "07z"=>:"07z", "08z"=>:"08z", "00z"=>:"00z",
             "21m"=>:"21m", "22m"=>:"22m", "23m"=>:"23m", "24m"=>:"24m", "25m"=>:"25m", "26m"=>:"26m", "27m"=>:"27m", "28m"=>:"28m", "29m"=>:"29m", "210m"=>:"210m",
             "21p"=>:"21p", "22p"=>:"22p", "23p"=>:"23p", "24p"=>:"24p", "25p"=>:"25p", "26p"=>:"26p", "27p"=>:"27p", "28p"=>:"28p", "29p"=>:"29p", "210p"=>:"210p",
             "21s"=>:"21s", "22s"=>:"22s", "23s"=>:"23s", "24s"=>:"24s", "25s"=>:"25s", "26s"=>:"26s", "27s"=>:"27s", "28s"=>:"28s", "29s"=>:"29s", "210s"=>:"210s", "200s"=>:"200s",
             "21t"=>:"21t", "22t"=>:"22t", "23t"=>:"23t", "24t"=>:"24t", "25t"=>:"25t", "26t"=>:"26t", "27t"=>:"27t", "28t"=>:"28t", "29t"=>:"29t", "210t"=>:"210t",
             "21z"=>:"21z", "22z"=>:"22z", "23z"=>:"23z", "24z"=>:"24z", "25z"=>:"25z", "26z"=>:"26z", "27z"=>:"27z", "28z"=>:"28z", "20z"=>:"20z",
             "31m"=>:"31m", "32m"=>:"32m", "33m"=>:"33m", "34m"=>:"34m", "35m"=>:"35m", "36m"=>:"36m", "37m"=>:"37m", "38m"=>:"38m", "39m"=>:"39m", "310m"=>:"310m",
             "31p"=>:"31p", "32p"=>:"32p", "33p"=>:"33p", "34p"=>:"34p", "35p"=>:"35p", "36p"=>:"36p", "37p"=>:"37p", "38p"=>:"38p", "39p"=>:"39p", "310p"=>:"310p",
             "31s"=>:"31s", "32s"=>:"32s", "33s"=>:"33s", "34s"=>:"34s", "35s"=>:"35s", "36s"=>:"36s", "37s"=>:"37s", "38s"=>:"38s", "39s"=>:"39s", "310s"=>:"310s", "300s"=>:"300s",
             "31t"=>:"31t", "32t"=>:"32t", "33t"=>:"33t", "34t"=>:"34t", "35t"=>:"35t", "36t"=>:"36t", "37t"=>:"37t", "38t"=>:"38t", "39t"=>:"39t", "310t"=>:"310t",
             "31z"=>:"31z", "32z"=>:"32z", "33z"=>:"33z", "34z"=>:"34z", "35z"=>:"35z", "36z"=>:"36z", "37z"=>:"37z", "38z"=>:"38z", "30z"=>:"30z",
             "41m"=>:"41m", "42m"=>:"42m", "43m"=>:"43m", "44m"=>:"44m", "45m"=>:"45m", "46m"=>:"46m", "47m"=>:"47m", "48m"=>:"48m", "49m"=>:"49m", "410m"=>:"410m",
             "41p"=>:"41p", "42p"=>:"42p", "43p"=>:"43p", "44p"=>:"44p", "45p"=>:"45p", "46p"=>:"46p", "47p"=>:"47p", "48p"=>:"48p", "49p"=>:"49p", "410p"=>:"410p",
             "41s"=>:"41s", "42s"=>:"42s", "43s"=>:"43s", "44s"=>:"44s", "45s"=>:"45s", "46s"=>:"46s", "47s"=>:"47s", "48s"=>:"48s", "49s"=>:"49s", "410s"=>:"410s", "400s"=>:"400s",
             "41t"=>:"41t", "42t"=>:"42t", "43t"=>:"43t", "44t"=>:"44t", "45t"=>:"45t", "46t"=>:"46t", "47t"=>:"47t", "48t"=>:"48t", "49t"=>:"49t", "410t"=>:"410t",
             "41z"=>:"41z", "42z"=>:"42z", "43z"=>:"43z", "44z"=>:"44z", "45z"=>:"45z", "46z"=>:"46z", "47z"=>:"47z", "48z"=>:"48z", "40z"=>:"40z",
             "1's"=>:"1's", "5'z"=>:"5'z", "5`z"=>:"5`z", "5^z"=>:"5^z",
             "01's"=>:"01's", "05'z"=>:"05'z", "05`z"=>:"05`z",
             "11's"=>:"11's", "15`z"=>:"15`z",
             "21's"=>:"21's", "25'z"=>:"25'z", "25`z"=>:"25`z",
             "31's"=>:"31's", "35'z"=>:"35'z", "35`z"=>:"35`z",
             "41's"=>:"41's", "45'z"=>:"45'z", "45`z"=>:"45`z",

             "any"=>:any, "faceup"=>:faceup,
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"10m"=>:"10m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"10p"=>:"10p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"10s"=>:"10s", :"0s"=>:"0s", :"00s"=>:"00s",
             :"1t"=>:"1t", :"2t"=>:"2t", :"3t"=>:"3t", :"4t"=>:"4t", :"5t"=>:"5t", :"6t"=>:"6t", :"7t"=>:"7t", :"8t"=>:"8t", :"9t"=>:"9t", :"10t"=>:"10t", :"0t"=>:"0t",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z", :"8z"=>:"8z", :"9z"=>:"9z", :"0z"=>:"0z",
             :"1x"=>:"1x", :"2x"=>:"2x", :"3x"=>:"3x", :"4x"=>:"4x", :"5x"=>:"5x", :"6x"=>:"6x", :"7x"=>:"7x", :"8x"=>:"8x",
             :"1f"=>:"1f", :"2f"=>:"2f", :"3f"=>:"3f", :"4f"=>:"4f",
             :"1g"=>:"1g", :"2g"=>:"2g", :"3g"=>:"3g", :"4g"=>:"4g",
             :"1a"=>:"1a", :"2a"=>:"2a", :"3a"=>:"3a", :"4a"=>:"4a",
             :"1k"=>:"1k", :"2k"=>:"2k", :"3k"=>:"3k", :"4k"=>:"4k",
             :"1q"=>:"1q", :"2q"=>:"2q", :"3q"=>:"3q", :"4q"=>:"4q",
             :"1y"=>:"1y", :"2y"=>:"2y",
             :"0j"=>:"0j", :"1j"=>:"1j", :"2j"=>:"2j", :"3j"=>:"3j", :"4j"=>:"4j", :"5j"=>:"5j", :"6j"=>:"6j", :"7j"=>:"7j", :"8j"=>:"8j", :"9j"=>:"9j",
             :"10j"=>:"10j", :"12j"=>:"12j", :"13j"=>:"13j", :"14j"=>:"14j", :"15j"=>:"15j", :"16j"=>:"16j", :"17j"=>:"17j", :"18j"=>:"18j",
             :"19j"=>:"19j", :"37j"=>:"37j", :"46j"=>:"46j", :"147j"=>:"147j", :"258j"=>:"258j", :"369j"=>:"369j", :"123j"=>:"123j", :"456j"=>:"456j", :"789j"=>:"789j",
             :"91j"=>:"91j", :"73j"=>:"73j", :"64j"=>:"64j", :"852j"=>:"852j", :"20j"=>:"20j", :"11j"=>:"11j", :"22j"=>:"22j",
             :"30j"=>:"30j", :"31j"=>:"31j", :"32j"=>:"32j", :"33j"=>:"33j", :"34j"=>:"34j",
             :"11m"=>:"11m", :"12m"=>:"12m", :"13m"=>:"13m", :"14m"=>:"14m", :"15m"=>:"15m", :"16m"=>:"16m", :"17m"=>:"17m", :"18m"=>:"18m", :"19m"=>:"19m", :"110m"=>:"110m",
             :"11p"=>:"11p", :"12p"=>:"12p", :"13p"=>:"13p", :"14p"=>:"14p", :"15p"=>:"15p", :"16p"=>:"16p", :"17p"=>:"17p", :"18p"=>:"18p", :"19p"=>:"19p", :"110p"=>:"110p",
             :"11s"=>:"11s", :"12s"=>:"12s", :"13s"=>:"13s", :"14s"=>:"14s", :"15s"=>:"15s", :"16s"=>:"16s", :"17s"=>:"17s", :"18s"=>:"18s", :"19s"=>:"19s", :"110s"=>:"110s", :"100s"=>:"100s",
             :"11t"=>:"11t", :"12t"=>:"12t", :"13t"=>:"13t", :"14t"=>:"14t", :"15t"=>:"15t", :"16t"=>:"16t", :"17t"=>:"17t", :"18t"=>:"18t", :"19t"=>:"19t", :"110t"=>:"110t",
             :"11z"=>:"11z", :"12z"=>:"12z", :"13z"=>:"13z", :"14z"=>:"14z", :"15z"=>:"15z", :"16z"=>:"16z", :"17z"=>:"17z", :"18z"=>:"18z",
             :"01m"=>:"01m", :"02m"=>:"02m", :"03m"=>:"03m", :"04m"=>:"04m", :"05m"=>:"05m", :"06m"=>:"06m", :"07m"=>:"07m", :"08m"=>:"08m", :"09m"=>:"09m", :"010m"=>:"010m",
             :"01p"=>:"01p", :"02p"=>:"02p", :"03p"=>:"03p", :"04p"=>:"04p", :"05p"=>:"05p", :"06p"=>:"06p", :"07p"=>:"07p", :"08p"=>:"08p", :"09p"=>:"09p", :"010p"=>:"010p",
             :"01s"=>:"01s", :"02s"=>:"02s", :"03s"=>:"03s", :"04s"=>:"04s", :"05s"=>:"05s", :"06s"=>:"06s", :"07s"=>:"07s", :"08s"=>:"08s", :"09s"=>:"09s", :"010s"=>:"010s", :"000s"=>:"000s",
             :"01t"=>:"01t", :"02t"=>:"02t", :"03t"=>:"03t", :"04t"=>:"04t", :"05t"=>:"05t", :"06t"=>:"06t", :"07t"=>:"07t", :"08t"=>:"08t", :"09t"=>:"09t", :"010t"=>:"010t",
             :"01z"=>:"01z", :"02z"=>:"02z", :"03z"=>:"03z", :"04z"=>:"04z", :"05z"=>:"05z", :"06z"=>:"06z", :"07z"=>:"07z", :"08z"=>:"08z", :"00z"=>:"00z",
             :"21m"=>:"21m", :"22m"=>:"22m", :"23m"=>:"23m", :"24m"=>:"24m", :"25m"=>:"25m", :"26m"=>:"26m", :"27m"=>:"27m", :"28m"=>:"28m", :"29m"=>:"29m", :"210m"=>:"210m",
             :"21p"=>:"21p", :"22p"=>:"22p", :"23p"=>:"23p", :"24p"=>:"24p", :"25p"=>:"25p", :"26p"=>:"26p", :"27p"=>:"27p", :"28p"=>:"28p", :"29p"=>:"29p", :"210p"=>:"210p",
             :"21s"=>:"21s", :"22s"=>:"22s", :"23s"=>:"23s", :"24s"=>:"24s", :"25s"=>:"25s", :"26s"=>:"26s", :"27s"=>:"27s", :"28s"=>:"28s", :"29s"=>:"29s", :"210s"=>:"210s", :"200s"=>:"200s",
             :"21t"=>:"21t", :"22t"=>:"22t", :"23t"=>:"23t", :"24t"=>:"24t", :"25t"=>:"25t", :"26t"=>:"26t", :"27t"=>:"27t", :"28t"=>:"28t", :"29t"=>:"29t", :"210t"=>:"210t",
             :"21z"=>:"21z", :"22z"=>:"22z", :"23z"=>:"23z", :"24z"=>:"24z", :"25z"=>:"25z", :"26z"=>:"26z", :"27z"=>:"27z", :"28z"=>:"28z", :"20z"=>:"20z",
             :"31m"=>:"31m", :"32m"=>:"32m", :"33m"=>:"33m", :"34m"=>:"34m", :"35m"=>:"35m", :"36m"=>:"36m", :"37m"=>:"37m", :"38m"=>:"38m", :"39m"=>:"39m", :"310m"=>:"310m",
             :"31p"=>:"31p", :"32p"=>:"32p", :"33p"=>:"33p", :"34p"=>:"34p", :"35p"=>:"35p", :"36p"=>:"36p", :"37p"=>:"37p", :"38p"=>:"38p", :"39p"=>:"39p", :"310p"=>:"310p",
             :"31s"=>:"31s", :"32s"=>:"32s", :"33s"=>:"33s", :"34s"=>:"34s", :"35s"=>:"35s", :"36s"=>:"36s", :"37s"=>:"37s", :"38s"=>:"38s", :"39s"=>:"39s", :"310s"=>:"310s", :"300s"=>:"300s",
             :"31t"=>:"31t", :"32t"=>:"32t", :"33t"=>:"33t", :"34t"=>:"34t", :"35t"=>:"35t", :"36t"=>:"36t", :"37t"=>:"37t", :"38t"=>:"38t", :"39t"=>:"39t", :"310t"=>:"310t",
             :"31z"=>:"31z", :"32z"=>:"32z", :"33z"=>:"33z", :"34z"=>:"34z", :"35z"=>:"35z", :"36z"=>:"36z", :"37z"=>:"37z", :"38z"=>:"38z", :"30z"=>:"30z",
             :"41m"=>:"41m", :"42m"=>:"42m", :"43m"=>:"43m", :"44m"=>:"44m", :"45m"=>:"45m", :"46m"=>:"46m", :"47m"=>:"47m", :"48m"=>:"48m", :"49m"=>:"49m", :"410m"=>:"410m",
             :"41p"=>:"41p", :"42p"=>:"42p", :"43p"=>:"43p", :"44p"=>:"44p", :"45p"=>:"45p", :"46p"=>:"46p", :"47p"=>:"47p", :"48p"=>:"48p", :"49p"=>:"49p", :"410p"=>:"410p",
             :"41s"=>:"41s", :"42s"=>:"42s", :"43s"=>:"43s", :"44s"=>:"44s", :"45s"=>:"45s", :"46s"=>:"46s", :"47s"=>:"47s", :"48s"=>:"48s", :"49s"=>:"49s", :"410s"=>:"410s", :"400s"=>:"400s",
             :"41t"=>:"41t", :"42t"=>:"42t", :"43t"=>:"43t", :"44t"=>:"44t", :"45t"=>:"45t", :"46t"=>:"46t", :"47t"=>:"47t", :"48t"=>:"48t", :"49t"=>:"49t", :"410t"=>:"410t",
             :"41z"=>:"41z", :"42z"=>:"42z", :"43z"=>:"43z", :"44z"=>:"44z", :"45z"=>:"45z", :"46z"=>:"46z", :"47z"=>:"47z", :"48z"=>:"48z", :"40z"=>:"40z",
             :"1's"=>:"1's", :"5'z"=>:"5'z", :"5`z"=>:"5`z", :"5^z"=>:"5^z",
             :"01's"=>:"01's", :"05'z"=>:"05'z", :"05`z"=>:"05`z",
             :"11's"=>:"11's", :"15`z"=>:"15`z",
             :"21's"=>:"21's", :"25'z"=>:"25'z", :"25`z"=>:"25`z",
             :"31's"=>:"31's", :"35'z"=>:"35'z", :"35`z"=>:"35`z",
             :"41's"=>:"41's", :"45'z"=>:"45'z", :"45`z"=>:"45`z",
             :any=>:any, :faceup=>:faceup,
            }

  def to_tile, do: @to_tile

  @tile_color %{:"1m"=>"pink", :"2m"=>"pink", :"3m"=>"pink", :"4m"=>"pink", :"5m"=>"pink", :"6m"=>"pink", :"7m"=>"pink", :"8m"=>"pink", :"9m"=>"pink", :"0m"=>"red",
                :"1p"=>"lightblue", :"2p"=>"lightblue", :"3p"=>"lightblue", :"4p"=>"lightblue", :"5p"=>"lightblue", :"6p"=>"lightblue", :"7p"=>"lightblue", :"8p"=>"lightblue", :"9p"=>"lightblue", :"0p"=>"red",
                :"1s"=>"lightgreen", :"2s"=>"lightgreen", :"3s"=>"lightgreen", :"4s"=>"lightgreen", :"5s"=>"lightgreen", :"6s"=>"lightgreen", :"7s"=>"lightgreen", :"8s"=>"lightgreen", :"9s"=>"lightgreen", :"0s"=>"red",
                :"1x"=>"orange", :"2x"=>"gray", :"3x"=>"gray", :"4x"=>"gray", :"5x"=>"gray", :"6x"=>"gray", :"7x"=>"gray", :"8x"=>"gray",
                :"01m"=>"red", :"02m"=>"red", :"03m"=>"red", :"04m"=>"red", :"05m"=>"red", :"06m"=>"red", :"07m"=>"red", :"08m"=>"red", :"09m"=>"red", :"010m"=>"red",
                :"01p"=>"red", :"02p"=>"red", :"03p"=>"red", :"04p"=>"red", :"05p"=>"red", :"06p"=>"red", :"07p"=>"red", :"08p"=>"red", :"09p"=>"red", :"010p"=>"red",
                :"01s"=>"red", :"02s"=>"red", :"03s"=>"red", :"04s"=>"red", :"05s"=>"red", :"06s"=>"red", :"07s"=>"red", :"08s"=>"red", :"09s"=>"red", :"010s"=>"red", :"000s"=>"red",
                :"01t"=>"red", :"02t"=>"red", :"03t"=>"red", :"04t"=>"red", :"05t"=>"red", :"06t"=>"red", :"07t"=>"red", :"08t"=>"red", :"09t"=>"red", :"010t"=>"red",
                :"01z"=>"red", :"02z"=>"red", :"03z"=>"red", :"04z"=>"red", :"05z"=>"red", :"06z"=>"red", :"07z"=>"red", :"00z"=>"red",
                :"11m"=>"cyan", :"12m"=>"cyan", :"13m"=>"cyan", :"14m"=>"cyan", :"15m"=>"cyan", :"16m"=>"cyan", :"17m"=>"cyan", :"18m"=>"cyan", :"19m"=>"cyan", :"110m"=>"cyan",
                :"11p"=>"cyan", :"12p"=>"cyan", :"13p"=>"cyan", :"14p"=>"cyan", :"15p"=>"cyan", :"16p"=>"cyan", :"17p"=>"cyan", :"18p"=>"cyan", :"19p"=>"cyan", :"110p"=>"cyan",
                :"11s"=>"cyan", :"12s"=>"cyan", :"13s"=>"cyan", :"14s"=>"cyan", :"15s"=>"cyan", :"16s"=>"cyan", :"17s"=>"cyan", :"18s"=>"cyan", :"19s"=>"cyan", :"110s"=>"cyan", :"100s"=>"cyan",
                :"11t"=>"cyan", :"12t"=>"cyan", :"13t"=>"cyan", :"14t"=>"cyan", :"15t"=>"cyan", :"16t"=>"cyan", :"17t"=>"cyan", :"18t"=>"cyan", :"19t"=>"cyan", :"110t"=>"cyan",
                :"11z"=>"cyan", :"12z"=>"cyan", :"13z"=>"cyan", :"14z"=>"cyan", :"15z"=>"cyan", :"16z"=>"cyan", :"17z"=>"cyan",
                :"21m"=>"blue", :"22m"=>"blue", :"23m"=>"blue", :"24m"=>"blue", :"25m"=>"blue", :"26m"=>"blue", :"27m"=>"blue", :"28m"=>"blue", :"29m"=>"blue", :"210m"=>"blue",
                :"21p"=>"blue", :"22p"=>"blue", :"23p"=>"blue", :"24p"=>"blue", :"25p"=>"blue", :"26p"=>"blue", :"27p"=>"blue", :"28p"=>"blue", :"29p"=>"blue", :"210p"=>"blue",
                :"21s"=>"blue", :"22s"=>"blue", :"23s"=>"blue", :"24s"=>"blue", :"25s"=>"blue", :"26s"=>"blue", :"27s"=>"blue", :"28s"=>"blue", :"29s"=>"blue", :"210s"=>"blue", :"200s"=>"blue",
                :"21t"=>"blue", :"22t"=>"blue", :"23t"=>"blue", :"24t"=>"blue", :"25t"=>"blue", :"26t"=>"blue", :"27t"=>"blue", :"28t"=>"blue", :"29t"=>"blue", :"210t"=>"blue",
                :"21z"=>"blue", :"22z"=>"blue", :"23z"=>"blue", :"24z"=>"blue", :"25z"=>"blue", :"26z"=>"blue", :"27z"=>"blue", :"20z"=>"blue",
                :"31m"=>"gold", :"32m"=>"gold", :"33m"=>"gold", :"34m"=>"gold", :"35m"=>"gold", :"36m"=>"gold", :"37m"=>"gold", :"38m"=>"gold", :"39m"=>"gold", :"310m"=>"gold",
                :"31p"=>"gold", :"32p"=>"gold", :"33p"=>"gold", :"34p"=>"gold", :"35p"=>"gold", :"36p"=>"gold", :"37p"=>"gold", :"38p"=>"gold", :"39p"=>"gold", :"310p"=>"gold",
                :"31s"=>"gold", :"32s"=>"gold", :"33s"=>"gold", :"34s"=>"gold", :"35s"=>"gold", :"36s"=>"gold", :"37s"=>"gold", :"38s"=>"gold", :"39s"=>"gold", :"310s"=>"gold", :"300s"=>"gold",
                :"31t"=>"gold", :"32t"=>"gold", :"33t"=>"gold", :"34t"=>"gold", :"35t"=>"gold", :"36t"=>"gold", :"37t"=>"gold", :"38t"=>"gold", :"39t"=>"gold", :"310t"=>"gold",
                :"31z"=>"gold", :"32z"=>"gold", :"33z"=>"gold", :"34z"=>"gold", :"35z"=>"gold", :"36z"=>"gold", :"37z"=>"gold", :"30z"=>"gold",
                :"1's"=>"lightgreen",
                :"01's"=>"red", :"05'z"=>"red", :"05`z"=>"red",
                :"11's"=>"cyan", :"15`z"=>"cyan",
                :"21's"=>"blue", :"25'z"=>"blue", :"25`z"=>"blue",
                :"31's"=>"gold", :"35'z"=>"gold", :"35`z"=>"gold",
               }
    
  def tile_color, do: @tile_color

  def sort_value(tile) do
    {tile, _attrs} = Utils.to_attr_tile(tile)
    case tile do
      :"1m" ->  10; :"2m" ->  20; :"3m" ->  30; :"4m" ->  40; :"0m" ->  50; :"5m" ->  51; :"6m" ->  60; :"7m" ->  70; :"8m" ->  80; :"9m" ->  90; :"10m" -> 95;
      :"1p" -> 110; :"2p" -> 120; :"3p" -> 130; :"4p" -> 140; :"0p" -> 150; :"5p" -> 151; :"6p" -> 160; :"7p" -> 170; :"8p" -> 180; :"9p" -> 190; :"10p" -> 195;
      :"1s" -> 210; :"2s" -> 220; :"3s" -> 230; :"4s" -> 240; :"0s" -> 250; :"5s" -> 251; :"6s" -> 260; :"7s" -> 270; :"8s" -> 280; :"9s" -> 290; :"10s" -> 295;
      :"1t" -> 310; :"2t" -> 320; :"3t" -> 330; :"4t" -> 340; :"0t" -> 350; :"5t" -> 351; :"6t" -> 360; :"7t" -> 370; :"8t" -> 380; :"9t" -> 390; :"10t" -> 395;
      :"1z" -> 1310; :"2z" -> 1320; :"3z" -> 1330; :"4z" -> 1340; :"0z" -> 1350; :"5z" -> 1351; :"8z" -> 1352; :"9z" -> 1353; :"6z" -> 1360; :"7z" -> 1370;

      :"01m" -> 9; :"02m" -> 19; :"03m" -> 29; :"04m" -> 39; :"05m" -> 47; :"06m" -> 59; :"07m" -> 69; :"08m" -> 79; :"09m" -> 89; :"010m" -> 94;
      :"01p" -> 109; :"02p" -> 119; :"03p" -> 129; :"04p" -> 139; :"05p" -> 147; :"06p" -> 159; :"07p" -> 169; :"08p" -> 179; :"09p" -> 189; :"010p" -> 194;
      :"01s" -> 209; :"02s" -> 219; :"03s" -> 229; :"04s" -> 239; :"05s" -> 247; :"06s" -> 259; :"07s" -> 269; :"08s" -> 279; :"09s" -> 289; :"010s" -> 294;
      :"01t" -> 309; :"02t" -> 319; :"03t" -> 329; :"04t" -> 339; :"05t" -> 347; :"06t" -> 359; :"07t" -> 369; :"08t" -> 379; :"09t" -> 389; :"010t" -> 394;
      :"01z" -> 1309; :"02z" -> 1319; :"03z" -> 1329; :"04z" -> 1339; :"00z" -> 1348; :"05z" -> 1349; :"06z" -> 1359; :"07z" -> 1369; :"08z" -> 1379;
      
      :"11m" ->  12; :"12m" ->  22; :"13m" ->  32; :"14m" ->  42; :"15m" ->  52; :"16m" ->  62; :"17m" ->  72; :"18m" ->  82; :"19m" ->  92; :"110m" ->  96;
      :"11p" -> 112; :"12p" -> 122; :"13p" -> 132; :"14p" -> 142; :"15p" -> 152; :"16p" -> 162; :"17p" -> 172; :"18p" -> 182; :"19p" -> 192; :"110p" -> 196;
      :"11s" -> 212; :"12s" -> 222; :"13s" -> 232; :"14s" -> 242; :"15s" -> 252; :"16s" -> 262; :"17s" -> 272; :"18s" -> 282; :"19s" -> 292; :"110s" -> 296;
      :"11t" -> 312; :"12t" -> 322; :"13t" -> 332; :"14t" -> 342; :"15t" -> 352; :"16t" -> 362; :"17t" -> 372; :"18t" -> 382; :"19t" -> 392; :"110t" -> 396;
      :"11z" -> 1312; :"12z" -> 1322; :"13z" -> 1332; :"14z" -> 1342; :"15z" -> 1353; :"16z" -> 1362; :"17z" -> 1372; :"18z" -> 1382;

      :"21m" ->  14; :"22m" ->  24; :"23m" ->  34; :"24m" ->  44; :"25m" ->  54; :"26m" ->  64; :"27m" ->  74; :"28m" ->  84; :"29m" ->  94; :"210m" ->  96;
      :"21p" -> 114; :"22p" -> 124; :"23p" -> 134; :"24p" -> 144; :"25p" -> 154; :"26p" -> 164; :"27p" -> 174; :"28p" -> 184; :"29p" -> 194; :"210p" -> 196;
      :"21s" -> 214; :"22s" -> 224; :"23s" -> 234; :"24s" -> 244; :"25s" -> 254; :"26s" -> 264; :"27s" -> 274; :"28s" -> 284; :"29s" -> 294; :"210s" -> 296;
      :"21t" -> 314; :"22t" -> 324; :"23t" -> 334; :"24t" -> 344; :"25t" -> 354; :"26t" -> 364; :"27t" -> 374; :"28t" -> 384; :"29t" -> 394; :"210t" -> 396;
      :"21z" -> 1314; :"22z" -> 1324; :"23z" -> 1334; :"24z" -> 1344; :"20z" -> 1354; :"25z" -> 1355; :"26z" -> 1364; :"27z" -> 1374; :"28z" -> 1384;

      :"31m" ->  16; :"32m" ->  26; :"33m" ->  36; :"34m" ->  46; :"35m" ->  56; :"36m" ->  66; :"37m" ->  76; :"38m" ->  86; :"39m" ->  96; :"310m" ->  96;
      :"31p" -> 116; :"32p" -> 126; :"33p" -> 136; :"34p" -> 146; :"35p" -> 156; :"36p" -> 166; :"37p" -> 176; :"38p" -> 186; :"39p" -> 196; :"310p" -> 196;
      :"31s" -> 216; :"32s" -> 226; :"33s" -> 236; :"34s" -> 246; :"35s" -> 256; :"36s" -> 266; :"37s" -> 276; :"38s" -> 286; :"39s" -> 296; :"310s" -> 296;
      :"31t" -> 316; :"32t" -> 326; :"33t" -> 336; :"34t" -> 346; :"35t" -> 356; :"36t" -> 366; :"37t" -> 376; :"38t" -> 386; :"39t" -> 396; :"310t" -> 396;
      :"31z" -> 1316; :"32z" -> 1326; :"33z" -> 1336; :"34z" -> 1346; :"30z" -> 1356; :"35z" -> 1357; :"36z" -> 1366; :"37z" -> 1376; :"38z" -> 1386;

      :"41m" ->  18; :"42m" ->  28; :"43m" ->  38; :"44m" ->  48; :"45m" ->  58; :"46m" ->  68; :"47m" ->  78; :"48m" ->  88; :"49m" ->  98; :"410m" ->  98;
      :"41p" -> 118; :"42p" -> 128; :"43p" -> 138; :"44p" -> 148; :"45p" -> 158; :"46p" -> 168; :"47p" -> 178; :"48p" -> 188; :"49p" -> 198; :"410p" -> 198;
      :"41s" -> 218; :"42s" -> 228; :"43s" -> 238; :"44s" -> 248; :"45s" -> 258; :"46s" -> 268; :"47s" -> 278; :"48s" -> 288; :"49s" -> 298; :"410s" -> 298;
      :"41t" -> 318; :"42t" -> 328; :"43t" -> 338; :"44t" -> 348; :"45t" -> 358; :"46t" -> 368; :"47t" -> 378; :"48t" -> 388; :"49t" -> 398; :"410t" -> 398;
      :"41z" -> 1318; :"42z" -> 1328; :"43z" -> 1338; :"44z" -> 1348; :"40z" -> 1358; :"45z" -> 1359; :"46z" -> 1368; :"47z" -> 1378; :"48z" -> 1388;

      :"1f" -> 12380; :"2f" -> 12390; :"3f" -> 12400; :"4f" -> 12410;
      :"1g" -> 12420; :"2g" -> 12430; :"3g" -> 12440; :"4g" -> 12450;
      :"1a" -> 12460; :"2a" -> 12470; :"3a" -> 12480; :"4a" -> 12490;
      :"1k" -> 12620; :"2k" -> 12630; :"3k" -> 12640; :"4k" -> 12650;
      :"1q" -> 12660; :"2q" -> 12670; :"3q" -> 12680; :"4q" -> 12690;
      :"1y" -> 12700;

      :"1j" -> 13000; :"2y" -> 13010;
      :"0j" -> 13020; :"6j" -> 13030; :"7j" -> 13040; :"8j" -> 13050; :"2j" -> 13060; :"3j" -> 13070; :"9j" -> 13080; :"4j" -> 13090; :"5j" -> 13100; 
      :"10j" -> 13110; :"16j" -> 13120; :"17j" -> 13130; :"18j" -> 13140; :"12j" -> 13150; :"13j" -> 13160; :"14j" -> 13170; :"15j" -> 13180; 
      :"19j" -> 13190; :"37j" -> 13200; :"46j" -> 13210; :"147j" -> 13220; :"258j" -> 13230; :"369j" -> 13240; :"123j" -> 13250; :"456j" -> 13260; :"789j" -> 13270;
      :"91j" -> 13280; :"73j" -> 13290; :"64j" -> 13300; :"852j" -> 13310; :"20j" -> 13320; :"11j" -> 13330; :"22j" -> 13340;
      :"30j" -> 13350; :"31j" -> 13360; :"32j" -> 13370; :"33j" -> 13380; :"34j" -> 13390;

      :"1x" -> 15000; :"2x" -> 15001; :"3x" -> 15002; :"4x" -> 15003; :"5x" -> 15004; :"6x" -> 15005; :"7x" -> 15006; :"8x" -> 15007;

      :"1's" -> 210; :"5'z" -> 1350; :"5`z" -> 1350; :"5^z" -> 1350;
      :"01's" -> 209; :"05'z" -> 1349; :"05`z" -> 1349;
      :"11's" -> 212; :"15`z" -> 1352;
      :"21's" -> 214; :"25'z" -> 1354; :"25`z" -> 1354;
      :"31's" -> 216; :"35'z" -> 1356; :"35`z" -> 1356;
      :"41's" -> 218; :"45'z" -> 1358; :"45`z" -> 1358;

      _ ->
        IO.puts("Unrecognized tile #{inspect(tile)}, cannot sort!")
        0
    end
  end

  @ai_names [
    "Betaori (AI)",
    "Chombo (AI)",
    "Furiten (AI)",
    "Jigoku (AI)",
    "Noten (AI)",
    "Oyakaburi (AI)",
    "Pao (AI)",
    "Penchan (AI)",
    "Tobi (AI)",
    "Uushanten (AI)",
    "Yakitori (AI)",
    "Yakuless (AI)",
    "Yasume (AI)",
  ]

  def ai_names, do: @ai_names

  @available_rulesets [
    {"riichi",       "Riichi", "The classic riichi ruleset, now with an assortment of mods to pick and choose at your liking."},
    {"sanma",        "Sanma", "Three-player Riichi."},
    {"space",        "Space Mahjong", "Riichi, but sequences can wrap (891, 912), and you can make sequences from winds and dragons. In addition, you can chii from any direction, and form open kokushi (3 han)."},
    {"cosmic",       "Cosmic Riichi", "A Space Mahjong variant with mixed triplets, more yaku, and more calls."},
    {"galaxy",       "Galaxy Mahjong", "Riichi, but one of each tile is replaced with a blue galaxy tile that acts as a wildcard of its number. Galaxy winds are wind wildcards, and galaxy dragons are dragon wildcards."},
    {"kansai",       "Kansai Sanma", "Sanma, but you draw until the last visible dora indicator. In addition, all fives are akadora, fu is fixed at 30, there is no tsumo loss, and scores are rounded to the nearest 1000. Flowers act as nukidora in place of north winds, which are now yakuhai. Exhaustive draws in south round always result in a repeat regardless of who's tenpai."},
    {"chinitsu",     "Chinitsu", "Two-player variant where the only tiles are bamboo tiles. Try not to chombo!"},
    {"minefield",    "Minefield", "Two-player variant where you start with 34 tiles to make a mangan+ hand, and your remaining tiles are your discards."},
    {"saki",         "Sakicards v1.3", "Riichi, but everyone gets a different Saki power, which changes the game quite a bit. Some give you bonus han every time you use your power. Some let you recover dead discards. Some let you swap tiles around the entire board, including the dora indicator."},
    {"hk",           "Hong Kong", "Hong Kong Old Style mahjong. Three point minimum, everyone pays for a win, and win instantly if you have seven flowers."},
    {"sichuan",      "Sichuan Bloody", "Sichuan Bloody mahjong. Trade tiles, void a suit, and play until three players win (bloody end rules)."},
    {"mcr",          "MCR", "Mahjong Competition Rules. Has a scoring system of a different kind of complexity than Riichi."},
    {"taiwanese",    "Taiwanese", "16-tile mahjong with riichi mechanics."},
    {"bloody30faan", "Bloody 30-Faan Jokers", "Bloody end rules mahjong, with Vietnamese jokers, and somehow more yaku than MCR."},
    {"american",     "American (2024 NMJL)", "American mahjong. Assemble hands with jokers, and declare other players' hands dead. Rules are not available for this one."},
    {"vietnamese",   "Vietnamese", "Mahjong with eight differently powerful joker tiles."},
    {"malaysian",    "Malaysian", "Three-player mahjong with 16 flowers, a unique joker tile, and instant payouts."},
    {"singaporean",  "Singaporean", "Mahjong with various instant payouts and various unique ways to get penalized by pao."},
    {"custom",       "Custom", "Create and play your own custom ruleset."},
  ]
  @unimplemented_rulesets [
    {"fuzhou",       "Fuzhou", "16-tile mahjong with a version of dora that doesn't give you han, but becomes a unique winning condition by itself.", "https://old.reddit.com/r/Mahjong/comments/171izis/fuzhou_mahjong_rules_corrected/"},
    {"filipino",     "Filipino", "16-tile mahjong where all honor tiles are flower tiles.", "https://mahjongpros.com/blogs/mahjong-rules-and-scoring-tables/official-filipino-mahjong-rules"},
    {"visayan",      "Visayan", "16-tile mahjong where you can form dragon and wind sequences.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-filipino-visayan-mahjong"},
    {"tianjin",      "Tianjin", "Mahjong except the dora indicator actually indicates joker tiles.", "https://michaelxing.com/mahjong/instr.php"},
    {"ningbo",       "Ningbo", "Includes Tianjin mahjong joker tiles, but adds more yaku and played with a 4-tai minimum.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-ningbo-mahjong-rules"},
    {"hefei",        "Hefei", "Mahjong with no honor tiles, but you must have at least eight tiles of a single suit to win.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-hefei-mahjong"},
    {"changsha",     "Changsha", "Mahjong, but every win gets two chances at ura dora. However, a standard hand must have a pair of 22, 55, or 88.", "https://mahjongpros.com/blogs/how-to-play/beginners-guide-to-changsha-mahjong"},
    {"shenyang",     "Shenyang", "Mahjong, but every hand must be open, contain every suit, contain a terminal/honor, and contain either a triplet, kan, or dragon pair.", "https://peterish.com/riichi-docs/shenyang-mahjong-rules/"},
    {"korean",       "Korean", "Like Riichi but with a two-han minimum. There is also a side race to see who reaches three wins first.", "https://mahjongpros.com/blogs/mahjong-rules-and-scoring-tables/official-korean-mahjong-rules"},
    {"cn_classical", "Chinese Classical", "Mahjong but every pung and kong gives you points, and every hand pattern doubles your points.", "http://mahjong.wikidot.com/rules:chinese-classical-scoring"},
    {"zung_jung",    "Zung Jung", "Mahjong with an additive (rather than multiplicative) scoring system.", "https://www.zj-mahjong.info/zj33_rules_eng.html"},
    {"british",      "British", "No description provided.", "https://wonderfuloldthings.wordpress.com/wp-content/uploads/2013/09/british-rules-guide-to-mahjong-v2-1.pdf"},
    {"italian",      "Italian", "No description provided.", "https://www.fimj.it/wp-content/uploads/2012/01/111213_Regolamento_FIMJ_A4.pdf"},
    {"dutch",        "Dutch", "No description provided.", "https://mahjongbond.org/wp-content/uploads/2019/10/NMB-NTS-Spelregelboekje.pdf"},
    {"german",       "German", "No description provided.", "https://www-user.tu-chemnitz.de/~sontag/mahjongg/"},
    {"french",       "French", "No description provided.", "https://web.archive.org/web/20050203025449/http://mahjongg.free.fr/Regles.php3"},
    {"australian",   "Australian", "No description provided.", "https://balsallcommonu3a.org/Downloads/Mahjong%20Rules%20November%202016.pdf"},
  ]

  def available_rulesets, do: @available_rulesets
  def unimplemented_rulesets, do: @unimplemented_rulesets

  @modpacks %{
    "sanma" => %{
      display_name: "Sanma",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/sanma.md",
      ruleset: "riichi",
      mods: ["sanma"],
      default_mods: [],
    },
    "cosmic" => %{
      display_name: "Cosmic Riichi",
      tutorial_link: "https://docs.google.com/document/d/1F-NhQ5fdi5CnAyEqwNE_qWR0Og99NtCo2NGkvBc5EwU/edit",
      ruleset: "riichi",
      mods: ["cosmic_base"],
      default_mods: ["cosmic", "space", "kontsu", "yaku/kontsu_yaku", "yaku/chanfuun", "yaku/fuunburi", "yaku/uumensai_cosmic", "cosmic_calls", "yakuman_13_han", "yaku/tsubame_gaeshi", "yaku/kanburi", "yaku/uumensai", "yaku/isshoku_sanjun", "yaku/isshoku_yonjun"],
    },
    "nojokersmahjongleague" => %{
      display_name: "No Jokers Mahjong League 2024",
      tutorial_link: "https://docs.google.com/document/d/1APpd-YBnsKKssGmyLQiCp90Wk-06SlIScV1sKpJUbQo/edit?usp=sharing",
      ruleset: "riichi",
      mods: ["nojokersmahjongleague", "kiriage_mangan", "agarirenchan", "tenpairenchan", "dora", "ura", "kandora", "yaku/ippatsu", "tobi", "immediate_kan_dora", "head_bump", "no_double_yakuman"],
      default_mods: ["show_waits"],
    },
    "space" => %{
      display_name: "Space Mahjong",
      tutorial_link: "https://riichi.wiki/Space_mahjong",
      ruleset: "riichi",
      mods: [],
      default_mods: ["space"],
    },
    "galaxy" => %{
      display_name: "Galaxy Mahjong",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/galaxy.md",
      ruleset: "riichi",
      mods: [],
      default_mods: ["galaxy"],
    },
    "chinitsu" => %{
      display_name: "Chinitsu Challenge",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/chinitsu_challenge.md",
      ruleset: "riichi",
      mods: ["yaku/riichi", "chinitsu_challenge"],
      default_mods: ["chombo", "tobi", "yaku/renhou_yakuman", "no_honors"],
    },
    "minefield" => %{
      display_name: "Minefield",
      tutorial_link: "https://riichi.wiki/Minefield_mahjong",
      ruleset: "riichi",
      mods: ["minefield"],
      default_mods: ["kiriage_mangan"],
    },
    "kansai" => %{
      display_name: "Kansai Sanma",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/kansai.md",
      ruleset: "riichi",
      mods: ["sanma", "kansai"],
      default_mods: ["tobi"],
    },
    "aka_test" => %{
      display_name: "Kansai Sanma",
      tutorial_link: "https://github.com/EpicOrange/riichi_advanced/blob/main/documentation/kansai.md",
      ruleset: "riichi",
      mods: ["sanma", %{name: "aka", config: %{"man" => 1, "pin" => 1, "sou" => 1}}],
      default_mods: ["tobi"],
    },
    "speed" => %{
      display_name: "Speed Mahjong",
      ruleset: "riichi",
      mods: ["kan", "yaku/riichi", "speed"]
    }
  }

  def modpacks, do: @modpacks

  @tutorials %{
    "riichi" => [
      {"riichi_basics", "Basic flow of the game", :east},
      {"riichi_calls", "Calling tiles", :north}
    ],
    "sanma" => [
      {"sanma_vs_riichi", "Differences from four-player", :south}
    ],
    "space" => [
      {"space_basics", "Intro to space mahjong", :east}
    ],
    "cosmic" => [
      {"cosmic_basics", "Intro to cosmic mahjong", :west}
    ],
    "galaxy" => [
      {"galaxy_basics", "Intro to galaxy mahjong", :west},
      {"galaxy_milky_way", "Milky Way", :south}
    ]
  }

  def tutorials, do: @tutorials

end