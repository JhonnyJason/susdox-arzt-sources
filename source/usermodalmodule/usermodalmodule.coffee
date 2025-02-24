############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usermodalmodule")
#endregion

############################################################
import * as logoutModal from "./logoutmodal.js"

############################################################
export initialize = ->
    log "initialize"
    logoutModal.initialize()
    return
