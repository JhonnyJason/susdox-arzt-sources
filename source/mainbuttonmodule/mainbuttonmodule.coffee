############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("mainbuttonmodule")
#endregion

############################################################
import * as triggers from "./navtriggers.js"
import * as credentialsFrame from "./credentialsframemodule.js"
import * as uiState from "./uistatemodule.js"

############################################################
addCodeButton = document.getElementById("add-account-button")
acceptButton = document.getElementById("accept-button")

############################################################
export initialize = ->
    log "initialize"
    addCodeButton.addEventListener("click", addCodeButtonClicked)
    acceptButton.addEventListener("click", acceptButtonClicked)
    return

############################################################
addCodeButtonClicked = (evnt) ->
    log "addCodeButtonClicked"
    # evnt.preventDefault()
    triggers.addAccount()
    # return false
    return

############################################################
export acceptButtonClicked = (evnt) ->
    log "acceptButtonClicked"
    # evnt.preventDefault()

    acceptButton.classList.add("disabled")
    currentBase = uiState.getBase()

    olog { currentBase }

    switch currentBase
        when "add-account", "update-account" 
            await credentialsFrame.acceptInput()
    
    acceptButton.classList.remove("disabled")
    # return false
    return
