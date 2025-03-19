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
          case System.cmd("python3", args, stderr_to_stdout: true) do
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

  # deprecated

  # def merge_jsons!(json1, json2) do
  #   {fd1, json1_path} = Temp.open!(%{mode: [:write, :utf8]})
  #   IO.write(fd1, json1)
  #   File.close(fd1)
  #   {fd2, json2_path} = Temp.open!(%{mode: [:write, :utf8]})
  #   IO.write(fd2, json2)
  #   File.close(fd2)

  #   try do
  #     args = ["-s", ".[0] * .[1]", json1_path, json2_path]
  #     case System.cmd("jq", args, stderr_to_stdout: true) do
  #       {_, code} = error when is_integer(code) and code != 0 ->
  #         raise(SystemCmdException, result: error, command: "jq", args: args)

  #       {value, code} when is_integer(code) and code == 0 ->
  #         result = value
  #         unless result, do: raise(NoResultException)

  #         # postprocess the result
  #         fd = File.open!(json1_path, [:write, :utf8])
  #         IO.write(fd, result)
  #         File.close(fd)
  #         args = ["formatter.py", json1_path, "2", "180", "8"]
  #         case System.cmd("python3", args, stderr_to_stdout: true) do
  #           {_, code} = error when is_integer(code) and code != 0 ->
  #             raise(SystemCmdException, result: error, command: "python", args: args)

  #           {value, code} when is_integer(code) and code == 0 ->
  #             result = value
  #             unless result, do: raise(NoResultException)
  #             result

  #           error ->
  #             raise(UnknownException, error)
  #         end
  #       error ->
  #         raise(UnknownException, error)
  #     end
  #   after
  #     File.rm!(json1_path)
  #     File.rm!(json2_path)
  #   end
  # end

end
