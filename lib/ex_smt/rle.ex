defmodule ExSMT.RLE do
  def encode(bin, %Regex{} = scan_pat, cluster_sz) when is_binary(bin) and is_integer(cluster_sz) and cluster_sz >= 1 do
    {scan_bin, last_partial_cluster} = case rem(byte_size(bin), cluster_sz) do
      0 -> {bin, ""}
      n when n > 0 -> :erlang.split_binary(bin, byte_size(bin) - n)
    end

    {output, raw_size} =
      Regex.scan(scan_pat, scan_bin, capture: :first)
      |> encode_parts(cluster_sz, last_partial_cluster)

    case raw_size / byte_size(bin) do
      n when n < 0.5 -> {:compressed, output}
      _ -> {:uncompressed, bin}
    end
  end

  defp encode_parts(parts, cluster_sz, last_partial_cluster) do
    {parts_acc, raw_len} = encode_part(parts, [], 0, cluster_sz)

    case byte_size(last_partial_cluster) do
      0 ->
        {:lists.reverse(parts_acc), raw_len}
      n when n > 0 ->
        {:lists.reverse([{:raw, last_partial_cluster} | parts_acc]), raw_len + n}
    end
  end

  defp encode_part([], acc, raw_len, _cluster_sz), do:
    {acc, raw_len}

  defp encode_part([[short] | rest], acc, raw_len, cluster_sz) when div(byte_size(short), cluster_sz) < 4, do:
    encode_part(rest, [{:raw, short} | acc], raw_len + byte_size(short), cluster_sz)

  defp encode_part([[long] | rest], acc, raw_len, cluster_sz) do
    <<cluster::binary-size(cluster_sz), _::binary>> = long
    encode_part(rest, [{:repeat, cluster, div(byte_size(long), cluster_sz)} | acc], raw_len, cluster_sz)
  end
end
