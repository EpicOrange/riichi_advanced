defmodule RiichiAdvanced.YakuTest.Sichuan do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.TestUtils, as: TestUtils

  test "sichuan standard yaku" do
    # root 2
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2m", :"2m", :"2m", :"2m", :"3m", :"4m", :"7p", :"7p", :"7p", :"7p", :"8s", :"9p", :"6p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Root", 2}]
    })
    # all triplets (actually suuankou tanki)
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2m", :"2m", :"2m", :"5m", :"5m", :"5m", :"7p", :"7p", :"7p", :"8p", :"8p", :"8p", :"6p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"All Triplets", 1}]
    })
    # all triplets full flush (also suuankou tanki)
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2p", :"2p", :"2p", :"5p", :"5p", :"5p", :"7p", :"7p", :"7p", :"8p", :"8p", :"8p", :"6p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"All Triplets", 1}, {"Full Flush", 2}]
    })
    # seven pairs full flush (actually daisharin)
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"2p", :"2p", :"3p", :"3p", :"4p", :"4p", :"5p", :"5p", :"6p", :"7p", :"7p", :"8p", :"8p"],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Seven Pairs", 2}, {"Full Flush", 2}]
    })
    # all triplets is overridden by golden single wait
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"6p"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}, {"pon", [:"3m", :"3m", :"3m"]}, {"pon", [:"5m", :"5m", :"5m"]}, {"daiminkan", [:"7m", :"7m", :"7m", :"7m"]}],
      winning_tile: :"6p",
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Root", 1}, {"Golden Single Wait", 2}]
    })
    # win after kong
    TestUtils.test_yaku("sichuan", [], %{
      hand: [:"6p"],
      calls: [{"pon", [:"2p", :"2p", :"2p"]}, {"pon", [:"3m", :"3m", :"3m"]}, {"pon", [:"5m", :"5m", :"5m"]}, {"daiminkan", [:"7m", :"7m", :"7m", :"7m"]}],
      winning_tile: :"6p",
      status: ["kan"],
      win_source: :discard,
      yaku_lists: ["yaku", "meta_yaku"],
      expected_yaku: [{"Root", 1}, {"Golden Single Wait", 2}, {"Win After Kong", 1}]
    })
    
  end

end
