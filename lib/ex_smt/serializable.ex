defprotocol ExSMT.Serializable do
  def serialize_bool(t)
  def serialize_int(t)
end

defimpl ExSMT.Serializable, for: Atom do
  def serialize_bool(true), do: "true"
  def serialize_bool(false), do: "false"
  def serialize_bool(nil), do: "false"
  def serialize_bool(a) when is_atom(a), do:
    ["|", to_string(a), "|"]

  def serialize_int(true), do: "1"
  def serialize_int(false), do: "0"
  def serialize_int(nil), do: "0"
  def serialize_int(a) when is_atom(a), do:
    ["(not (= |", to_string(a), "| 0))"]
end

defimpl ExSMT.Serializable, for: Integer do
  def serialize_bool(0), do: "false"
  def serialize_bool(n) when is_integer(n), do: "true"

  def serialize_int(n) when is_integer(n), do: Integer.to_string(n)
end
