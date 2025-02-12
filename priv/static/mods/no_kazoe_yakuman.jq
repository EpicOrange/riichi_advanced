(.score_calculation.limit_thresholds | map(.[0] >= 13) | index(true)) as $ix
|
.score_calculation.limit_thresholds |= .[:$ix]
|
.score_calculation.limit_scores |= .[:$ix]
|
.score_calculation.limit_names |= .[:$ix]
