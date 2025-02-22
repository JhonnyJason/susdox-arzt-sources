import Modules from "./allmodules"
import domconnect from "./indexdomconnect"
domconnect.initialize()

import { appLoaded } from "navhandler"
global.allModules = Modules

############################################################
if navigator? and navigator.serviceWorker? then navigator.serviceWorker.register("serviceworker.js")

############################################################
appStartup = -> 
    # footer.addEventListener("click", footerClicked)
    appLoaded()
    return

############################################################
run = ->
    promises = (m.initialize() for n,m of Modules when m.initialize?) 
    await Promise.all(promises)
    appStartup()

############################################################
run()

############################################################
# doubleClickHack

# ############################################################
# lastContentClick = 0

# ############################################################
# footerClicked = (evnt) ->
#     console.log "footerClicked"
#     console.log lastContentClick
#     currentContentClick = performance.now()
#     delta = currentContentClick - lastContentClick
#     lastContentClick = currentContentClick
#     if delta < 400 then doubleClickHappened()
#     return

# doubleClickHappened = ->
#     console.log "doubleClickHappened"
#     lastContentClick = 0
#     window.open("https://orientation-experiment.dotv.ee", '_blank');
#     return
