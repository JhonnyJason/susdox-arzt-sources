############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("navtriggers")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as S from "./statemodule.js"
import {setSustSolLogo} from "./radiologistdatamodule.js"
# import {setQRCode} from "./radiologistdatamodule.js"

############################################################
## Navigation Action Triggers

############################################################
export home = ->
    navState = S.get("navState")
    if navState.depth == 0 then setSustSolLogo()
    # if navState.depth == 0 then setQRCode()
    else return nav.toRoot(true)
    
############################################################
export menu = (menuOn) ->
    if menuOn then return nav.toMod("menu")
    else return nav.toMod("none")
 
############################################################
export logout = ->
    return nav.toMod("logoutconfirmation")

############################################################
export addAccount = ->
    return await nav.toBaseAt("add-account", null, 1)

############################################################
export accountUpdate = ->
    return await nav.toBaseAt("update-account", null, 1)

############################################################
export requestCode = ->
    return await nav.toBase("request-code")

############################################################
export requestUpdateCode = ->
    return await nav.toBase("request-update-account")

############################################################
export patientSelect = (ctx) ->
    return await nav.toBaseAt("patient-table", ctx, 1)

############################################################
# export codeReveal = (toReveal) ->
#     if toReveal then return nav.toMod("coderevealed")
#     else return nav.toMod("none")

############################################################
# export invalidCode = ->
#     return nav.toMod("invalidcode")

# export showQR = ->
#     return nav.toBase("show-qr")
    
# ############################################################
# export screeningsList = ->
#     return nav.toBase("screenings-list")

############################################################
export reload = ->
    window.location.reload()
    return
