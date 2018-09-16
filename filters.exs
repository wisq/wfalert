import WFAlert.Filter.Helpers

alert_filters([
  default(:show)
])

invasion_filters([
  filter(:show, fn r -> r.name == "Mutagen Mass" && r.quantity >= 2 end),
  default(:hide)
])
