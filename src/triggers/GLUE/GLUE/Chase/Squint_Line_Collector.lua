if not GLUE or not GLUE.chase then return end
if line:find("Narrowing your eyes", 1, true) then return end
if line:find("impaled by a narrow bone", 1, true) then return end

GLUE.chase._squintLines[#GLUE.chase._squintLines + 1] = line
