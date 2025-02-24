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
    table.unsetPatient()

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
    table.unsetPatient()

    cubeModule.reset()
    credentialsFrame.prepareForAddCode()

    content.classList.remove("preload")
    content.classList.add("add-account")
    content.classList.remove("logging-in")
    content.classList.remove("request-code")

    realBody.classList.remove("table")
    return

############################################################
export setToLoggingInState = ->
    log "setToLoggingInState"
    table.unsetPatient()

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

    realBody.classList.add("table")
    return

#endregion
