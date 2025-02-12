defmodule RiichiAdvanced.Constants do
  alias RiichiAdvanced.Utils, as: Utils

  @version "v1.1.0." <> (System.cmd("git", ["rev-parse", "--short", "HEAD"]) |> elem(0) |> String.trim())

  def version, do: @version

  @to_tile %{"1m"=>:"1m", "2m"=>:"2m", "3m"=>:"3m", "4m"=>:"4m", "5m"=>:"5m", "6m"=>:"6m", "7m"=>:"7m", "8m"=>:"8m", "9m"=>:"9m", "0m"=>:"0m",
             "1p"=>:"1p", "2p"=>:"2p", "3p"=>:"3p", "4p"=>:"4p", "5p"=>:"5p", "6p"=>:"6p", "7p"=>:"7p", "8p"=>:"8p", "9p"=>:"9p", "0p"=>:"0p",
             "1s"=>:"1s", "2s"=>:"2s", "3s"=>:"3s", "4s"=>:"4s", "5s"=>:"5s", "6s"=>:"6s", "7s"=>:"7s", "8s"=>:"8s", "9s"=>:"9s", "0s"=>:"0s",
             "1t"=>:"1t", "2t"=>:"2t", "3t"=>:"3t", "4t"=>:"4t", "5t"=>:"5t", "6t"=>:"6t", "7t"=>:"7t", "8t"=>:"8t", "9t"=>:"9t", "0t"=>:"0t",
             "1z"=>:"1z", "2z"=>:"2z", "3z"=>:"3z", "4z"=>:"4z", "5z"=>:"5z", "6z"=>:"6z", "7z"=>:"7z", "0z"=>:"0z", "8z"=>:"8z",
             "1x"=>:"1x", "2x"=>:"2x", "3x"=>:"3x", "4x"=>:"4x",
             "1f"=>:"1f", "2f"=>:"2f", "3f"=>:"3f", "4f"=>:"4f",
             "1g"=>:"1g", "2g"=>:"2g", "3g"=>:"3g", "4g"=>:"4g",
             "1a"=>:"1a", "2a"=>:"2a", "3a"=>:"3a", "4a"=>:"4a",
             "1y"=>:"1y", "2y"=>:"2y",
             "0j"=>:"0j", "1j"=>:"1j", "2j"=>:"2j", "3j"=>:"3j", "4j"=>:"4j", "5j"=>:"5j", "6j"=>:"6j", "7j"=>:"7j", "8j"=>:"8j", "9j"=>:"9j",
             "10j"=>:"10j", "12j"=>:"12j", "13j"=>:"13j", "14j"=>:"14j", "15j"=>:"15j", "16j"=>:"16j", "17j"=>:"17j", "18j"=>:"18j",
             "19j"=>:"19j", "37j"=>:"37j", "46j"=>:"46j", "147j"=>:"147j", "258j"=>:"258j", "369j"=>:"369j", "123j"=>:"123j", "456j"=>:"456j", "789j"=>:"789j",
             "91j"=>:"91j", "73j"=>:"73j", "64j"=>:"64j", "852j"=>:"852j", "20j"=>:"20j", "11j"=>:"11j", "22j"=>:"22j",
             "30j"=>:"30j", "31j"=>:"31j", "32j"=>:"32j", "33j"=>:"33j", "34j"=>:"34j",
             "1k"=>:"1k", "2k"=>:"2k", "3k"=>:"3k", "4k"=>:"4k",
             "1q"=>:"1q", "2q"=>:"2q", "3q"=>:"3q", "4q"=>:"4q",
             "11m"=>:"11m", "12m"=>:"12m", "13m"=>:"13m", "14m"=>:"14m", "15m"=>:"15m", "16m"=>:"16m", "17m"=>:"17m", "18m"=>:"18m", "19m"=>:"19m",
             "11p"=>:"11p", "12p"=>:"12p", "13p"=>:"13p", "14p"=>:"14p", "15p"=>:"15p", "16p"=>:"16p", "17p"=>:"17p", "18p"=>:"18p", "19p"=>:"19p",
             "11s"=>:"11s", "12s"=>:"12s", "13s"=>:"13s", "14s"=>:"14s", "15s"=>:"15s", "16s"=>:"16s", "17s"=>:"17s", "18s"=>:"18s", "19s"=>:"19s",
             "11t"=>:"11t", "12t"=>:"12t", "13t"=>:"13t", "14t"=>:"14t", "15t"=>:"15t", "16t"=>:"16t", "17t"=>:"17t", "18t"=>:"18t", "19t"=>:"19t",
             "11z"=>:"11z", "12z"=>:"12z", "13z"=>:"13z", "14z"=>:"14z", "15z"=>:"15z", "16z"=>:"16z", "17z"=>:"17z",
             "110m"=>:"110m", "110p"=>:"110p", "110s"=>:"110s", "110t"=>:"110t",
             "10m"=>:"10m", "10p"=>:"10p", "10s"=>:"10s", "10t"=>:"10t",
             "25z"=>:"25z", "26z"=>:"26z", "27z"=>:"27z",
             "01m"=>:"01m", "02m"=>:"02m", "03m"=>:"03m", "04m"=>:"04m", "05m"=>:"05m", "25m"=>:"25m", "35m"=>:"35m", "06m"=>:"06m", "07m"=>:"07m", "08m"=>:"08m", "09m"=>:"09m", "010m"=>:"010m",
             "01p"=>:"01p", "02p"=>:"02p", "03p"=>:"03p", "04p"=>:"04p", "05p"=>:"05p", "25p"=>:"25p", "35p"=>:"35p", "06p"=>:"06p", "07p"=>:"07p", "08p"=>:"08p", "09p"=>:"09p", "010p"=>:"010p",
             "01s"=>:"01s", "02s"=>:"02s", "03s"=>:"03s", "04s"=>:"04s", "05s"=>:"05s", "25s"=>:"25s", "35s"=>:"35s", "06s"=>:"06s", "07s"=>:"07s", "08s"=>:"08s", "09s"=>:"09s", "010s"=>:"010s",
             "01t"=>:"01t", "02t"=>:"02t", "03t"=>:"03t", "04t"=>:"04t", "05t"=>:"05t", "25t"=>:"25t", "35t"=>:"35t", "06t"=>:"06t", "07t"=>:"07t", "08t"=>:"08t", "09t"=>:"09t", "010t"=>:"010t",
             "01z"=>:"01z", "02z"=>:"02z", "03z"=>:"03z", "04z"=>:"04z", "05z"=>:"05z", "06z"=>:"06z", "07z"=>:"07z", "00z"=>:"00z",
             "any"=>:any, "faceup"=>:faceup,
             :"1m"=>:"1m", :"2m"=>:"2m", :"3m"=>:"3m", :"4m"=>:"4m", :"5m"=>:"5m", :"6m"=>:"6m", :"7m"=>:"7m", :"8m"=>:"8m", :"9m"=>:"9m", :"0m"=>:"0m",
             :"1p"=>:"1p", :"2p"=>:"2p", :"3p"=>:"3p", :"4p"=>:"4p", :"5p"=>:"5p", :"6p"=>:"6p", :"7p"=>:"7p", :"8p"=>:"8p", :"9p"=>:"9p", :"0p"=>:"0p",
             :"1s"=>:"1s", :"2s"=>:"2s", :"3s"=>:"3s", :"4s"=>:"4s", :"5s"=>:"5s", :"6s"=>:"6s", :"7s"=>:"7s", :"8s"=>:"8s", :"9s"=>:"9s", :"0s"=>:"0s",
             :"1t"=>:"1t", :"2t"=>:"2t", :"3t"=>:"3t", :"4t"=>:"4t", :"5t"=>:"5t", :"6t"=>:"6t", :"7t"=>:"7t", :"8t"=>:"8t", :"9t"=>:"9t", :"0t"=>:"0t",
             :"1z"=>:"1z", :"2z"=>:"2z", :"3z"=>:"3z", :"4z"=>:"4z", :"5z"=>:"5z", :"6z"=>:"6z", :"7z"=>:"7z", :"0z"=>:"0z", :"8z"=>:"8z",
             :"1x"=>:"1x", :"2x"=>:"2x", :"3x"=>:"3x", :"4x"=>:"4x",
             :"1f"=>:"1f", :"2f"=>:"2f", :"3f"=>:"3f", :"4f"=>:"4f",
             :"1g"=>:"1g", :"2g"=>:"2g", :"3g"=>:"3g", :"4g"=>:"4g",
             :"1a"=>:"1a", :"2a"=>:"2a", :"3a"=>:"3a", :"4a"=>:"4a",
             :"1y"=>:"1y", :"2y"=>:"2y",
             :"0j"=>:"0j", :"1j"=>:"1j", :"2j"=>:"2j", :"3j"=>:"3j", :"4j"=>:"4j", :"5j"=>:"5j", :"6j"=>:"6j", :"7j"=>:"7j", :"8j"=>:"8j", :"9j"=>:"9j",
             :"10j"=>:"10j", :"12j"=>:"12j", :"13j"=>:"13j", :"14j"=>:"14j", :"15j"=>:"15j", :"16j"=>:"16j", :"17j"=>:"17j", :"18j"=>:"18j",
             :"19j"=>:"19j", :"37j"=>:"37j", :"46j"=>:"46j", :"147j"=>:"147j", :"258j"=>:"258j", :"369j"=>:"369j", :"123j"=>:"123j", :"456j"=>:"456j", :"789j"=>:"789j",
             :"91j"=>:"91j", :"73j"=>:"73j", :"64j"=>:"64j", :"852j"=>:"852j", :"20j"=>:"20j", :"11j"=>:"11j", :"22j"=>:"22j",
             :"30j"=>:"30j", :"31j"=>:"31j", :"32j"=>:"32j", :"33j"=>:"33j", :"34j"=>:"34j",
             :"1k"=>:"1k", :"2k"=>:"2k", :"3k"=>:"3k", :"4k"=>:"4k",
             :"1q"=>:"1q", :"2q"=>:"2q", :"3q"=>:"3q", :"4q"=>:"4q",
             :"11m"=>:"11m", :"12m"=>:"12m", :"13m"=>:"13m", :"14m"=>:"14m", :"15m"=>:"15m", :"16m"=>:"16m", :"17m"=>:"17m", :"18m"=>:"18m", :"19m"=>:"19m",
             :"11p"=>:"11p", :"12p"=>:"12p", :"13p"=>:"13p", :"14p"=>:"14p", :"15p"=>:"15p", :"16p"=>:"16p", :"17p"=>:"17p", :"18p"=>:"18p", :"19p"=>:"19p",
             :"11s"=>:"11s", :"12s"=>:"12s", :"13s"=>:"13s", :"14s"=>:"14s", :"15s"=>:"15s", :"16s"=>:"16s", :"17s"=>:"17s", :"18s"=>:"18s", :"19s"=>:"19s",
             :"11t"=>:"11t", :"12t"=>:"12t", :"13t"=>:"13t", :"14t"=>:"14t", :"15t"=>:"15t", :"16t"=>:"16t", :"17t"=>:"17t", :"18t"=>:"18t", :"19t"=>:"19t",
             :"11z"=>:"11z", :"12z"=>:"12z", :"13z"=>:"13z", :"14z"=>:"14z", :"15z"=>:"15z", :"16z"=>:"16z", :"17z"=>:"17z",
             :"110m"=>:"110m", :"110p"=>:"110p", :"110s"=>:"110s", :"110t"=>:"110t",
             :"10m"=>:"10m", :"10p"=>:"10p", :"10s"=>:"10s", :"10t"=>:"10t",
             :"25z"=>:"25z", :"26z"=>:"26z", :"27z"=>:"27z",
             :"01m"=>:"01m", :"02m"=>:"02m", :"03m"=>:"03m", :"04m"=>:"04m", :"05m"=>:"05m", :"25m"=>:"25m", :"35m"=>:"35m", :"06m"=>:"06m", :"07m"=>:"07m", :"08m"=>:"08m", :"09m"=>:"09m", :"010m"=>:"010m",
             :"01p"=>:"01p", :"02p"=>:"02p", :"03p"=>:"03p", :"04p"=>:"04p", :"05p"=>:"05p", :"25p"=>:"25p", :"35p"=>:"35p", :"06p"=>:"06p", :"07p"=>:"07p", :"08p"=>:"08p", :"09p"=>:"09p", :"010p"=>:"010p",
             :"01s"=>:"01s", :"02s"=>:"02s", :"03s"=>:"03s", :"04s"=>:"04s", :"05s"=>:"05s", :"25s"=>:"25s", :"35s"=>:"35s", :"06s"=>:"06s", :"07s"=>:"07s", :"08s"=>:"08s", :"09s"=>:"09s", :"010s"=>:"010s",
             :"01t"=>:"01t", :"02t"=>:"02t", :"03t"=>:"03t", :"04t"=>:"04t", :"05t"=>:"05t", :"25t"=>:"25t", :"35t"=>:"35t", :"06t"=>:"06t", :"07t"=>:"07t", :"08t"=>:"08t", :"09t"=>:"09t", :"010t"=>:"010t",
             :"01z"=>:"01z", :"02z"=>:"02z", :"03z"=>:"03z", :"04z"=>:"04z", :"05z"=>:"05z", :"06z"=>:"06z", :"07z"=>:"07z", :"00z"=>:"00z",
             :any=>:any, :faceup=>:faceup,
            }

  def to_tile, do: @to_tile

  @tile_color %{:"1m"=>"pink", :"2m"=>"pink", :"3m"=>"pink", :"4m"=>"pink", :"5m"=>"pink", :"6m"=>"pink", :"7m"=>"pink", :"8m"=>"pink", :"9m"=>"pink", :"0m"=>"red",
                :"1p"=>"lightblue", :"2p"=>"lightblue", :"3p"=>"lightblue", :"4p"=>"lightblue", :"5p"=>"lightblue", :"6p"=>"lightblue", :"7p"=>"lightblue", :"8p"=>"lightblue", :"9p"=>"lightblue", :"0p"=>"red",
                :"1s"=>"lightgreen", :"2s"=>"lightgreen", :"3s"=>"lightgreen", :"4s"=>"lightgreen", :"5s"=>"lightgreen", :"6s"=>"lightgreen", :"7s"=>"lightgreen", :"8s"=>"lightgreen", :"9s"=>"lightgreen", :"0s"=>"red",
                :"1x"=>"orange", :"2x"=>"orange",
                :"11m"=>"cyan", :"12m"=>"cyan", :"13m"=>"cyan", :"14m"=>"cyan", :"15m"=>"cyan", :"16m"=>"cyan", :"17m"=>"cyan", :"18m"=>"cyan", :"19m"=>"cyan",
                :"11p"=>"cyan", :"12p"=>"cyan", :"13p"=>"cyan", :"14p"=>"cyan", :"15p"=>"cyan", :"16p"=>"cyan", :"17p"=>"cyan", :"18p"=>"cyan", :"19p"=>"cyan",
                :"11s"=>"cyan", :"12s"=>"cyan", :"13s"=>"cyan", :"14s"=>"cyan", :"15s"=>"cyan", :"16s"=>"cyan", :"17s"=>"cyan", :"18s"=>"cyan", :"19s"=>"cyan",
                :"11z"=>"cyan", :"12z"=>"cyan", :"13z"=>"cyan", :"14z"=>"cyan", :"15z"=>"cyan", :"16z"=>"cyan", :"17z"=>"cyan",
                :"25z"=>"blue", :"26z"=>"red", :"27z"=>"gold",
                :"01m"=>"red", :"02m"=>"red", :"03m"=>"red", :"04m"=>"red", :"05m"=>"red", :"25m"=>"blue", :"35m"=>"gold", :"06m"=>"red", :"07m"=>"red", :"08m"=>"red", :"09m"=>"red", :"010m"=>"red",
                :"01p"=>"red", :"02p"=>"red", :"03p"=>"red", :"04p"=>"red", :"05p"=>"red", :"25p"=>"blue", :"35p"=>"gold", :"06p"=>"red", :"07p"=>"red", :"08p"=>"red", :"09p"=>"red", :"010p"=>"red",
                :"01s"=>"red", :"02s"=>"red", :"03s"=>"red", :"04s"=>"red", :"05s"=>"red", :"25s"=>"blue", :"35s"=>"gold", :"06s"=>"red", :"07s"=>"red", :"08s"=>"red", :"09s"=>"red", :"010s"=>"red",
                :"01t"=>"red", :"02t"=>"red", :"03t"=>"red", :"04t"=>"red", :"05t"=>"red", :"25t"=>"blue", :"35t"=>"gold", :"06t"=>"red", :"07t"=>"red", :"08t"=>"red", :"09t"=>"red", :"010t"=>"red",
                :"01z"=>"red", :"02z"=>"red", :"03z"=>"red", :"04z"=>"red", :"05z"=>"red", :"06z"=>"red", :"07z"=>"red", :"00z"=>"red"
               }
    
  def tile_color, do: @tile_color

  def sort_value(tile) do
    {tile, _attrs} = Utils.to_attr_tile(tile)
    case tile do
      :"1m" ->  10; :"2m" ->  20; :"3m" ->  30; :"4m" ->  40; :"0m" ->  50; :"5m" ->  51; :"6m" ->  60; :"7m" ->  70; :"8m" ->  80; :"9m" ->  90; :"10m" -> 95;
      :"1p" -> 110; :"2p" -> 120; :"3p" -> 130; :"4p" -> 140; :"0p" -> 150; :"5p" -> 151; :"6p" -> 160; :"7p" -> 170; :"8p" -> 180; :"9p" -> 190; :"10p" -> 195;
      :"1s" -> 210; :"2s" -> 220; :"3s" -> 230; :"4s" -> 240; :"0s" -> 250; :"5s" -> 251; :"6s" -> 260; :"7s" -> 270; :"8s" -> 280; :"9s" -> 290; :"10s" -> 295;
      :"1t" -> 310; :"2t" -> 320; :"3t" -> 330; :"4t" -> 340; :"0t" -> 350; :"5t" -> 351; :"6t" -> 360; :"7t" -> 370; :"8t" -> 380; :"9t" -> 390; :"10t" -> 395;
      :"11m" ->  12; :"12m" ->  22; :"13m" ->  32; :"14m" ->  42; :"15m" ->  52; :"16m" ->  62; :"17m" ->  72; :"18m" ->  82; :"19m" ->  92; :"110m" ->  96;
      :"11p" -> 112; :"12p" -> 122; :"13p" -> 132; :"14p" -> 142; :"15p" -> 152; :"16p" -> 162; :"17p" -> 172; :"18p" -> 182; :"19p" -> 192; :"110p" -> 196;
      :"11s" -> 212; :"12s" -> 222; :"13s" -> 232; :"14s" -> 242; :"15s" -> 252; :"16s" -> 262; :"17s" -> 272; :"18s" -> 282; :"19s" -> 292; :"110s" -> 296;
      :"11t" -> 312; :"12t" -> 322; :"13t" -> 332; :"14t" -> 342; :"15t" -> 352; :"16t" -> 362; :"17t" -> 372; :"18t" -> 382; :"19t" -> 392; :"110t" -> 396;
      :"1z" -> 1310; :"2z" -> 1320; :"3z" -> 1330; :"4z" -> 1340; :"0z" -> 1350; :"5z" -> 1351; :"8z" -> 1352; :"6z" -> 1360; :"7z" -> 1370;
      :"11z" -> 1312; :"12z" -> 1322; :"13z" -> 1332; :"14z" -> 1342; :"15z" -> 1352; :"16z" -> 1362; :"17z" -> 1372;
      :"25z" -> 1353; :"26z" -> 1363; :"27z" -> 1373;

      :"1f" -> 2380; :"2f" -> 2390; :"3f" -> 2400; :"4f" -> 2410;
      :"1g" -> 2420; :"2g" -> 2430; :"3g" -> 2440; :"4g" -> 2450;
      :"1a" -> 2460; :"2a" -> 2470; :"3a" -> 2480; :"4a" -> 2490;
      :"1k" -> 2620; :"2k" -> 2630; :"3k" -> 2640; :"4k" -> 2650;
      :"1q" -> 2660; :"2q" -> 2670; :"3q" -> 2680; :"4q" -> 2690;
      :"1y" -> 2700;

      :"1j" -> 3000; :"2y" -> 3010;
      :"0j" -> 3020; :"6j" -> 3030; :"7j" -> 3040; :"8j" -> 3050; :"2j" -> 3060; :"3j" -> 3070; :"9j" -> 3080; :"4j" -> 3090; :"5j" -> 3100; 
      :"10j" -> 3110; :"16j" -> 3120; :"17j" -> 3130; :"18j" -> 3140; :"12j" -> 3150; :"13j" -> 3160; :"14j" -> 3170; :"15j" -> 3180; 
      :"19j" -> 3190; :"37j" -> 3200; :"46j" -> 3210; :"147j" -> 3220; :"258j" -> 3230; :"369j" -> 3240; :"123j" -> 3250; :"456j" -> 3260; :"789j" -> 3270;
      :"91j" -> 3280; :"73j" -> 3290; :"64j" -> 3300; :"852j" -> 3310; :"20j" -> 3320; :"11j" -> 3330; :"22j" -> 3340;
      :"30j" -> 3350; :"31j" -> 3360; :"32j" -> 3370; :"33j" -> 3380; :"34j" -> 3390;

      :"1x" -> 5000; :"2x" -> 5001; :"3x" -> 5002; :"4x" -> 5003;

      :"01m" -> 9; :"02m" -> 19; :"03m" -> 29; :"04m" -> 39; :"05m" -> 47; :"25m" -> 48; :"35m" -> 49; :"06m" -> 59; :"07m" -> 69; :"08m" -> 79; :"09m" -> 89; :"010m" -> 94;
      :"01p" -> 109; :"02p" -> 119; :"03p" -> 129; :"04p" -> 139; :"05p" -> 147; :"25p" -> 148; :"35p" -> 149; :"06p" -> 159; :"07p" -> 169; :"08p" -> 179; :"09p" -> 189; :"010p" -> 194;
      :"01s" -> 209; :"02s" -> 219; :"03s" -> 229; :"04s" -> 239; :"05s" -> 247; :"25s" -> 248; :"35s" -> 249; :"06s" -> 259; :"07s" -> 269; :"08s" -> 279; :"09s" -> 289; :"010s" -> 294;
      :"01t" -> 309; :"02t" -> 319; :"03t" -> 329; :"04t" -> 339; :"05t" -> 347; :"25t" -> 348; :"35t" -> 349; :"06t" -> 359; :"07t" -> 369; :"08t" -> 379; :"09t" -> 389; :"010t" -> 394;
      :"01z" -> 1309; :"02z" -> 1319; :"03z" -> 1329; :"04z" -> 1339; :"00z" -> 1348; :"05z" -> 1349; :"06z" -> 1359; :"07z" -> 1369;
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

end