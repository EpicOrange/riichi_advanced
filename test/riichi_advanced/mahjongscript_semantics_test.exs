defmodule RiichiAdvanced.MahjongScriptSemanticsTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Compiler, as: Compiler
  alias RiichiAdvanced.Parser, as: Parser

  # happy cases

  test "mahjongscript - if statement" do
    script = """
    def foo do
      if "true" do
        print("true!")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - if else statement" do
    script = """
    def foo do
      if "true" do
        print("true!")
      else
        print("false!")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - not condition" do
    script = """
    def foo do
      if "not_true" do
        print("true!")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end
  
  test "mahjongscript - and condition" do
    script = """
    def foo do
      if ("true" and "true") and ("true" and "true") and "true" do
        print("true!")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - or condition" do
    script = """
    def foo do
      if ("true" or "true") or ("true" or "true") or "true" do
        print("true!")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - nested and/or conditions" do
    script = """
    def foo do
      if "true" or ("true" and ("true" or "true")) do
        print("true!")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - set command variations" do
    script = """
    set name1, "example 1"
    set "name2", "example 2"
    set("name3", "example 3")
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    assert String.contains?(compiled, ".[\"name1\"] = \"example 1\"")
    assert String.contains?(compiled, ".[\"name2\"] = \"example 2\"")
    assert String.contains?(compiled, ".[\"name3\"] = \"example 3\"")
  end

  test "mahjongscript - on command variations" do
    script = """
    on after_win, after_win1
    on "after_win", after_win2
    on("after_win", after_win3)
    on("before_win", print("foo"))
    on "before_win" do
      print("bar")
      print("baz")
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    assert String.contains?(compiled, ".[\"after_win\"].actions += [[\"run\",\"after_win1\"]]")
    assert String.contains?(compiled, ".[\"after_win\"].actions += [[\"run\",\"after_win2\"]]")
    assert String.contains?(compiled, ".[\"after_win\"].actions += [[\"run\",\"after_win3\"]]")
    assert String.contains?(compiled, ".[\"before_win\"].actions += [[\"print\",\"foo\"]]")
    assert String.contains?(compiled, ".[\"before_win\"].actions += [[\"print\",\"bar\"],[\"print\",\"baz\"]]")
  end

  test "mahjongscript - single line def" do
    script = """
    def foo, do: print("asdf")
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - on handlers can have spaces" do
    script = """
    on foo, "has spaces"
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - def name can have spaces" do
    script = """
    def "has spaces" do
      print("hello")
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end

  test "mahjongscript - define_set" do
    script = """
    define_set myset, ~s"0 1 2"
    define_set myset, ~s"0@attr 1 2"
    define_set myset, ~s"0@attr&attr2 1 2"
    define_set myset, ~s"1m 2m 3m"
    define_set myset, ~s"0 1m 2p"
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, _compiled} = Compiler.compile_jq(parsed)
  end






















  # erroring cases

  test "mahjongscript - invalid root" do
    script = """
    123
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "invalid root node")
  end

  test "mahjongscript - invalid command" do
    script = """
    invalid_command foo, "bar"
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "not a valid toplevel command")
  end

  test "mahjongscript - invalid condition" do
    script = """
    def foo do
      if invalid_condition() do
        print("test")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "not a valid condition")
  end

  test "mahjongscript - invalid number as action" do
    script = """
    def foo do
      123
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expected an action")
  end

  test "mahjongscript - invalid number as condition" do
    script = """
    def foo do
      if 123 do
        print("test")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expecting a condition")
  end
  test "mahjongscript - invalid list as action" do
    script = """
    def foo do
      [1, 2, 3]
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expected an action")
  end

  test "mahjongscript - invalid list as condition" do
    script = """
    def foo do
      if [1, 2, 3] do
        print("test")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expecting a condition")
  end

  test "mahjongscript - invalid map as action" do
    script = """
    def foo do
      %{"a" => 1}
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expected an action")
  end

  test "mahjongscript - invalid map as condition" do
    script = """
    def foo do
      if %{"a" => 1} do
        print("test")
      end
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expecting a condition")
  end

  test "mahjongscript - no string interpolation" do
    script = """
    def foo do
      print("test \(. | debug)")
      print("test \\(. | debug)")
      print("test \\\\(. | debug)")
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute String.contains?(compiled, " \\(")
  end

  test "mahjongscript - empty on command" do
    script = """
    on
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "command expects arguments")
  end

  test "mahjongscript - empty set command" do
    script = """
    set
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "command expects arguments")
  end

  test "mahjongscript - def must have do block" do
    script = """
    def foo, "not a do block"
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expected an action")
  end

  test "mahjongscript - def body contains a non-action" do
    script = """
    def foo do
      print("test")
      "not an action"
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expected an action")
  end

  test "mahjongscript - on body contains a non-action" do
    script = """
    on foo do
      print("test")
      "not an action"
    end
    """
    assert {:ok, parsed} = Parser.parse(script)
    assert {:error, msg} = Compiler.compile_jq(parsed)
    assert String.contains?(msg, "expected an action")
  end

















end
