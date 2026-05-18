local cmd = matches[2]
if cmd == "toggle" then
    GLUE.util.itemDB.toggle()
    GLUE.util.exploration.toggle()
elseif cmd == "save" then
    GLUE.util.itemDB.save()
    GLUE.util.exploration.saveStuff()
elseif cmd == "load" then
    GLUE.util.itemDB.load()
    GLUE.util.exploration.loadStuff()
elseif cmd == "validate" then
    GLUE.util.itemDB.validate()
end
