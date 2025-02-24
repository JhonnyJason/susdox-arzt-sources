############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("uistatemodule")
#endregion

############################################################
#region imported UI modules
import * as content from "./contentmodule.js"
import * as menu from "./menumodule.js"
import * as credentialsFrame from "./credentialsframemodule.js"
import * as logoutModal from "./logoutmodal.js"
import * as footer from "./footermodule.js"

#endregion

############################################################
applyBaseState = {}
applyModifier = {}

############################################################
currentBase = null
currentModifier = null
currentContext = null

############################################################
#region Base State Application Functions

applyBaseState["no-account"] = (ctx) ->
    content.setToDefaultState(ctx)
    footer.show()
    return

applyBaseState["add-account"] = (ctx) ->
    content.setToAddAccountState(ctx)
    footer.show()
    return

applyBaseState["logging-in"] = (ctx) ->
    content.setToLoggingInState(ctx)
    footer.show()
    return

applyBaseState["main-table"] = (ctx) ->
    content.setToMainTableState(ctx)    
    footer.hide()
    return

applyBaseState["patient-table"] = (ctx) ->
    content.setToPatientTableState(ctx)    
    footer.hide()
    return

#endregion

############################################################
resetAllModifications = ->
    menu.setMenuOff()
    logoutModal.turnDownModal("uiState changed")
    return

############################################################
#region Modifier State Application Functions

applyModifier["none"] = (ctx) ->
    resetAllModifications()
    return

applyModifier["menu"] = (ctx) ->
    resetAllModifications()
    menu.setMenuOn()
    footer.show()
    return

applyModifier["logoutconfirmation"] = (ctx) ->
    resetAllModifications()
    logoutModal.turnUpModal()
    footer.show()
    return

#endregion


############################################################
#region exported general Application Functions
export applyUIState = (base, modifier, ctx) ->
    log "applyUIState"
    currentContext = ctx

    if base? then applyUIStateBase(base)
    if modifier? then applyUIStateModifier(modifier)
    return

############################################################
export applyUIStateBase = (base) ->
    log "applyUIBaseState #{base}"
    applyBaseFunction = applyBaseState[base]

    if typeof applyBaseFunction != "function" then throw new Error("on applyUIStateBase: base '#{base}' apply function did not exist!")

    currentBase = base
    applyBaseFunction(currentContext)
    return

############################################################
export applyUIStateModifier = (modifier) ->
    log "applyUIStateModifier #{modifier}"
    applyModifierFunction = applyModifier[modifier]

    if typeof applyUIStateModifier != "function" then throw new Error("on applyUIStateModifier: modifier '#{modifier}' apply function did not exist!")

    currentModifier = modifier
    applyModifierFunction(currentContext)
    return

############################################################
export getModifier = -> currentModifier
export getBase = -> currentBase
export getContext = -> currentContext

#endregion