############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("headermodule")
#endregion

############################################################
import * as table from "./overviewtablemodule.js"
import * as S from "./statemodule.js"

############################################################
#region DOM Cache
backButton = document.getElementById("back-button")
searchButton = document.getElementById("search-button")
cancelSearchButton = document.getElementById("cancel-search-button")
#endregion

# ############################################################
# patientNameIndication = document.getElementById("patient-name-indication")

############################################################
export initialize = ->
    log "initialize"
    backButton.addEventListener("click", backButtonClicked)
    searchButton.addEventListener("click", searchButtonClicked)
    cancelSearchButton.addEventListener("click", cancelSearchButtonClicked)
    return


############################################################
cancelSearchButtonClicked = ->
    log "cancelSearchButtonClicked"
    table.cancelPatientSearch()
    return

searchButtonClicked = ->
    log "searchButtonClicked"
    table.startPatientSearch()
    return

backButtonClicked = ->
    log "backButtonClicked"
    table.backFromPatientTable()
    return


############################################################
export indicatePatient = (patientName, patientDob) ->
    patientNameIndication.textContent = patientName
    patientDobIndication.textContent = patientDob
    return

############################################################
export setPatientString = (patientString) ->
    patientNameIndication.textContent = patientString
    return
