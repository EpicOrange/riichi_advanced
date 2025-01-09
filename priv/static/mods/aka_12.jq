# directly replace all 5 with aka
def five_to_aka:
  if type == "array" then
    map(five_to_aka)
  elif type == "string" then
    if . == "5m" then "0m"
    elif . == "5p" then "0p"
    elif . == "5s" then "0s"
    else . end
  else
    .
  end;

.wall |= five_to_aka
