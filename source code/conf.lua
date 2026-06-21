--NOTE changing this to false can cause serious lag if the standard output gets
--redircted into a integrated terminal, If console is disabled also disable the global "debug_print"

function love.conf(t)
     t.console = false
end