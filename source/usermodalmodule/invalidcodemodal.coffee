############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usermodalmodule")
#endregion

############################################################
import M from "mustache"

############################################################
import { ModalCore } from "./modalcore.js"
import * as account from "./accountmodule.js"


############################################################
unnamedTextElement = document.getElementById("unnamed-text-element")
unnamedText = unnamedTextElement.textContent

############################################################
core = null

############################################################
messageTemplate = ""
messageElement = null

promiseConsumed = false
    
############################################################
updateButton = document.getElementById("invalidcodemodal-update-button")

############################################################
export initialize = ->
    log "initialize"
    core = new ModalCore(invalidcodemodal)
    core.connectDefaultElements()

    messageTemplate = invalidcodemodalContentMessageTemplate.innerHTML
    messageElement = invalidcodemodal.getElementsByClassName("modal-content")[0]
    
    updateButton.addEventListener("click", updateButtonClicked)
    return

############################################################
updateButtonClicked = (evnt) ->
    log "updateButtonClicked"
    if core.modalPromise? and !promiseConsumed
        core.modalPromise.catch(()->return)
        # core.modalPromise.catch((err) -> log("unconsumed: #{err}"))

    core.reject("updateButtonClicked")
    return

############################################################
export promptCodeDeletion = ->
    log "promptCodeDeletion"
    promiseConsumed = true
    return core.modalPromise

############################################################
#region UI State Manipulation

export turnUpModal = (reason) ->
    log "turnUpModal"
    return if core.modalPromise? # already up

    accountObj = account.getAccountObject()
    cObj = {}
    if accountObj.label == "" and accountObj.name? then cObj.label = accountObj.name  
    else if accountObj.label == "" then cObj.label = unnamedText
    else cObj.label = accountObj.label

    messageElement.innerHTML = M.render(messageTemplate, cObj)
    
    promiseConsumed = false
    core.activate()
    return

export turnDownModal = (reason) ->
    log "turnDownModal"
    if core.modalPromise? and !promiseConsumed 
        core.modalPromise.catch(()->return)
        # core.modalPromise.catch((err) -> log("unconsumed: #{err}"))

    core.reject(reason)
    promiseConsumed = false
    return

#endregion