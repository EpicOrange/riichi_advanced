defmodule JQ.SystemCmdException do
  defexception [:message]

  @impl true
  def exception(result: {message, code}, command: command, args: args) do
    %JQ.SystemCmdException{message: msg(result: {message, code}, command: command, args: args)}
  end

  defp msg(result: {message, code}, command: command, args: args) do
    """
    Error executing jq bash command.
      exit code: #{inspect(code)}
      message: #{inspect(message)}
      invocation: System.cmd(#{inspect(command)}, #{inspect(args)}
    """
  end
end

defmodule JQ.NoResultException do
  defexception message: "JQ query yielded no result"
end

defmodule JQ.MaxByteSizeExceededException do
  defexception [:message]

  @impl true
  def exception(size: size, max_byte_size: max_byte_size) do
    %JQ.MaxByteSizeExceededException{
      message:
        "input of #{inspect(size)} byte(s) exceeds the maximum allowed byte size of #{
          inspect(max_byte_size)
        } byte(s)."
    }
  end
end

defmodule JQ.UnknownException do
  defexception [:message]

  @impl true
  def exception(any) do
    %JQ.UnknownException{
      message: "unknown exception occurred while executing System.cmd. #{inspect(any)}"
    }
  end
end
