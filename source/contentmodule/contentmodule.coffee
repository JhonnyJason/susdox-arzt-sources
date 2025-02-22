############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("contentmodule")
#endregion

############################################################
import * as cubeModule from "./cubemodule.js"
import * as credentialsFrame from "./credentialsframemodule.js"
import * as requestFrame from "./requestcodeframemodule.js"
import * as table from "./overviewtablemodule.js"

############################################################
#region State Setter Functions
export setToDefaultState = ->
    log "setToDefaultState"
    cubeModule.reset()
    requestFrame.reset()
    credentialsFrame.reset()

    content.classList.remove("preload")
    content.classList.remove("add-account")
    content.classList.remove("logging-in")
    content.classList.remove("request-code")

    realBody.classList.remove("table")
    return

############################################################
export setToAddAccountState = ->
    log "setToAddAccountState"
    cubeModule.reset()
    credentialsFrame.prepareForAddCode()

    content.classList.remove("preload")
    content.classList.add("add-account")
    content.classList.remove("logging-in")
    content.classList.remove("request-code")

    realBody.classList.remove("table")
    return

############################################################
export setToUpdateAccountState = ->
    log "setToUpdateAccountState"
    cubeModule.reset()
    credentialsFrame.prepareForCodeUpdate()

    content.classList.remove("preload")
    content.classList.add("add-account")
    content.classList.remove("logging-in")
    content.classList.remove("request-code")

    realBody.classList.remove("table")
    return

############################################################
export setToRequestCodeState = ->
    log "setToRequestCodeState"
    cubeModule.reset()
    cubeModule.setRequestCodeFrame() # must be before requestFrame.prepareForRequest, otherwise the Frame is not in the DOM
    # credentialsFrame.reset() ## no need to reset here!
    requestFrame.prepareForRequest()

    content.classList.remove("preload")
    content.classList.remove("add-account")
    content.classList.remove("logging-in")
    content.classList.add("request-code")

    realBody.classList.remove("table")
    return

############################################################
export setToRequestUpdateCodeState = ->
    log "setToRequestUpdateCodeState"
    cubeModule.reset()
    cubeModule.setRequestCodeFrame() # must be before requestFrame.prepareForRequest, otherwise the Frame is not in the DOM
    # credentialsFrame.reset() ## no need to reset here!
    requestFrame.prepareForUpdateRequest()

    content.classList.remove("preload")
    content.classList.remove("add-account")
    content.classList.remove("logging-in")
    content.classList.add("request-code")

    realBody.classList.remove("table")
    return

############################################################
export setToLoggingInState = ->
    log "setToLoggingInState"
    cubeModule.reset()
    cubeModule.setPreloader()
    credentialsFrame.reset()
    requestFrame.reset()

    content.classList.remove("preload")
    content.classList.remove("add-account")
    content.classList.add("logging-in")
    content.classList.remove("request-code") 

    realBody.classList.remove("table")
    return

############################################################
export setToMainTableState = ->
    log "setToMainTableState"
    table.setDefaultState()

    cubeModule.reset()
    credentialsFrame.reset()
    requestFrame.reset()

    content.classList.remove("preload")
    content.classList.remove("add-account")
    content.classList.remove("logging-in")
    content.classList.remove("request-code")

    realBody.classList.add("table")
    return


export setToPatientTableState = (ctx) ->
    log "setToPatientTableState"
    table.setPatient(ctx)
    
    cubeModule.reset()
    credentialsFrame.reset()
    requestFrame.reset()

    content.classList.remove("preload")
    content.classList.remove("add-account")
    content.classList.remove("logging-in")
    content.classList.remove("request-code")    

    realBody.classList.remove("table")
    return

#endregion
