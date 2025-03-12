defmodule RiichiAdvanced.MahjongScriptSecurityTest do
  use ExUnit.Case, async: true
  alias RiichiAdvanced.Compiler, as: Compiler

  def is_unsafe_jq?(jq) do
    # pass in jq that executes `env`
    # IO.puts(jq)
    JQ.query_string_with_string!("{}", jq)
    |> String.contains?("PATH")
  end

  test "mahjongscript - jq test works" do
    assert is_unsafe_jq?("env")
    assert is_unsafe_jq?("$ENV")
    assert is_unsafe_jq?("\"\\(env\)\"")
  end

  test "mahjongscript - prevents JQ injection via set key" do
    script = """
    set("key\\\" | env", "key\\\" | env")
    """
    assert {:ok, parsed} = Compiler.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute is_unsafe_jq?(compiled)
  end

  test "mahjongscript - prevents JQ injection via function name" do
    script = """
    def "foo\\\" | env" do
      print("hello")
    end
    """
    assert {:ok, parsed} = Compiler.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute is_unsafe_jq?(compiled)
  end

  test "mahjongscript - prevents string escape injection" do
    script = """
    def foo do
      print("hello\\\" | env")
    end
    """
    assert {:ok, parsed} = Compiler.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute is_unsafe_jq?(compiled)
  end

  test "mahjongscript - prevents backtick injection" do
    script = """
    def foo do
      print("hello `env`")
    end
    """
    assert {:ok, parsed} = Compiler.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute is_unsafe_jq?(compiled)
  end

  test "mahjongscript - prevents dollar variable injection" do
    script = """
    def foo do
      print("$ENV")
      print("$ENV")
    end
    """
    assert {:ok, parsed} = Compiler.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute is_unsafe_jq?(compiled)
  end

  test "mahjongscript - prevents string interpolation injection" do
    script = """
    def foo do
      print("hello \\(. | env)")
      print("hello \\\\(. | env)")
      print("hello \\\\\\\\(. | env)")
    end
    """
    assert {:ok, parsed} = Compiler.parse(script)
    assert {:ok, compiled} = Compiler.compile_jq(parsed)
    refute is_unsafe_jq?(compiled)
  end

  test "mahjongscript - parse rejects scripts larger than 4MB" do
    script = "set #{String.duplicate("x", 4 * 1024 * 1024)}, 1"
    assert {:error, msg} = Compiler.parse(script)
    assert String.contains?(msg, "script too large")
  end

end
