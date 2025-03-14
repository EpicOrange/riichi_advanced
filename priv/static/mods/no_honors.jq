.after_initialization.actions += [["add_rule", "Rules", "Wall", "(No Honors) There are no honor tiles.", -99]]
|
.wall |= map(select(IN("1z","2z","3z","4z","5z","6z","7z","11z","12z","13z","14z","15z","16z","17z") | not))
