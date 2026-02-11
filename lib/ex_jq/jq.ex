defmodule JQ do
  alias JQ.{NoResultException, SystemCmdException, UnknownException}

  def query_string!(payload, query_path) do
    {fd, file_path} = Temp.open!(%{mode: [:write, :utf8]})
    IO.write(fd, payload)
    File.close(fd)

    try do
      args = ["-cf", query_path, file_path]
      case System.cmd("jq", args, stderr_to_stdout: true) do
        {_, code} = error when is_integer(code) and code != 0 ->
          raise(SystemCmdException, result: error, command: "jq", args: args)

        {value, code} when is_integer(code) and code == 0 ->
          result = value
          unless result, do: raise(NoResultException)
          RiichiAdvanced.Formatter.format(Jason.decode!(result), 80)
        error ->
          raise(UnknownException, error)
      end
    after
      File.rm!(file_path)
    end
  end

  def query_string_with_string!(payload, query) do
    # IO.puts(query)
    {fd, query_path} = Temp.open!(%{mode: [:write, :utf8]})
    IO.write(fd, query)
    File.close(fd)

    try do
      query_string!(payload, query_path)
    after
      File.rm!(query_path)
    end
  end
end