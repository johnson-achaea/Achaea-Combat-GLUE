if GLUE then GLUE.illusionActive = false end
if GLUE and GLUE.affQueue then GLUE.affQueue.Flush() end
if flushAffBuffer then flushAffBuffer() end
reportAffs = false
