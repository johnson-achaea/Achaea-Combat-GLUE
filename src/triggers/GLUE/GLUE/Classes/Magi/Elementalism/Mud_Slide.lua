-- Pattern: ^You weave earth and water and a torrent of thick mud thunders forth to roll over (\w+)\, knocking (\w+) sprawling\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("prone")
GLUE.state.AddAffliction("slickness")
