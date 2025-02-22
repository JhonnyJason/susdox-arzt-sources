############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usermodalmodule")
#endregion

############################################################
import * as logoutModal from "./logoutmodal.js"
import * as invalidcodeModal from "./invalidcodemodal.js"
import * as codeverificationModal from "./codeverificationmodal.js"

############################################################
export initialize = ->
    log "initialize"
    logoutModal.initialize()
    invalidcodeModal.initialize()
    codeverificationModal.initialize()
    return
