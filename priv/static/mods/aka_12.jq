.wall |= map(if . == "5m" then "0m" elif . == "5p" then "0p" elif . == "5s" then "0s" elif . == "5t" then "0t" else . end)
