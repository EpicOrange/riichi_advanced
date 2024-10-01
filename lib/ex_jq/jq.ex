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

          # postprocess the result
          fd = File.open!(file_path, [:write, :utf8])
          IO.write(fd, result)
          File.close(fd)
          args = ["formatter.py", file_path, "2", "180", "8"]
          case System.cmd("python", args, stderr_to_stdout: true) do
            {_, code} = error when is_integer(code) and code != 0 ->
              raise(SystemCmdException, result: error, command: "python", args: args)

            {value, code} when is_integer(code) and code == 0 ->
              result = value
              unless result, do: raise(NoResultException)
              result

            error ->
              raise(UnknownException, error)
          end
        error ->
          raise(UnknownException, error)
      end
    after
      File.rm!(file_path)
    end
  end

end
