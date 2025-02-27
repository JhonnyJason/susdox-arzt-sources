############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("appcoremodule")
#endregion

############################################################
#region Imported Modules
import * as nav from "navhandler"

############################################################
import * as S from "./statemodule.js"
import * as uiState from "./uistatemodule.js"
import * as triggers from "./navtriggers.js"
import * as utl from "./utilmodule.js"

############################################################
import * as account from "./accountmodule.js"

############################################################
import * as menuModule from "./menumodule.js"

############################################################
import * as logoutModal from "./logoutmodal.js"

############################################################
import * as sci from "./scimodule.js"

############################################################
import { AuthenticationError } from "./errormodule.js"
import { appVersion } from "./configmodule.js"
import { env } from "./environmentmodule.js"
import { logoutRequest } from "./scimodule.js"

#endregion

############################################################
serviceWorker = null
if navigator? and navigator.serviceWorker?
    serviceWorker = navigator.serviceWorker

############################################################
currentVersion = document.getElementById("current-version")
newVersion = document.getElementById("new-version")
menuVersion = document.getElementById("menu-version")

############################################################
appBaseState = "no-account"
appUIMod = "none"
urlCode = null

############################################################
accountAvailable = false
redirected = false

############################################################
export initialize = ->
    log "initialize"
    # nav.initialize(loadAppWithNavState, setNavState, true)
    nav.initialize(loadAppWithNavState, setNavState)

    currentVersion.textContent = appVersion
    
    if serviceWorker?
        serviceWorker.register("serviceworker.js", {scope: "/"})
        if serviceWorker.controller?
            serviceWorker.controller.postMessage("App is version: #{appVersion}!")
        serviceWorker.addEventListener("message", onServiceWorkerMessage)
        serviceWorker.addEventListener("controllerchange", onServiceWorkerSwitch)
    
    S.addOnChangeListener("activeAccount", activeAccountChanged)
    return

############################################################
#region internal Functions
setUIState = (base, mod, ctx) ->
    log "setUIState"

    switch base
        when "RootState"
            if accountAvailable then base = "main-table"
            else base = "no-account"

    ########################################
    setAppState(base, mod, ctx)

    switch mod
        when "logoutconfirmation" then confirmLogoutProcess()

    ########################################
    # setAppState(base, mod, ctx)
    return

############################################################
#region Event Listeners

loadAppWithNavState = (navState) ->
    log "loadAppWithNavState"
    baseState = navState.base
    modifier = navState.modifier
    context = navState.context
    S.save("navState", navState)

    urlCode = getCodeFromURL()
    await startUp()

    if urlCode? then return nav.toMod("codeverification")

    setUIState(baseState, modifier, context)
    
    if appBaseState == "no-account" then triggers.addAccount()
    return

############################################################
setNavState = (navState) ->
    log "setNavState"
    olog navState
    baseState = navState.base
    modifier = navState.modifier
    context = navState.context
    S.save("navState", navState)

    # reset always
    accountToUpdate = null
    
    setUIState(baseState, modifier, context)
    return

############################################################
activeAccountChanged = ->
    log "activeAccountChanged"
    await checkAccountAvailability()
    if accountAvailable then await prepareAccount()
    else # last account has been deleted
        setAppState("no-account","none")

    if redirected then return

    nav.toRoot(true)
    updateUIData()
    return

#endregion

############################################################
startUp = ->
    log "startUp"    
    await checkAccountAvailability()
    if accountAvailable then await prepareAccount()

    updateUIData()
    return

############################################################
checkAccountAvailability = ->
    log "checkAccountAvailability"
    try
        await account.getUserCredentials()
        accountAvailable = true
        return # return fast if we have an account
    catch err then log err
    # log "No Account Available"
    
    # no account available
    accountAvailable = false
    return

############################################################
prepareAccount = ->
    log "prepareAccount"
    setAppState("logging-in", "none")

    try
        await account.assertValidLogin()
        setAppState("main-table", "none")
        return
        
    catch err then log err # here credentials were invalid
    #delete invalid account then    
    account.deleteAccount()
    accountAvailable = false
    try logoutRequest()
    catch err then log err
    return
    
############################################################
updateUIData = ->
    log "updateUIData"
    # update data in the UIs
    menuModule.updateUser()
    return

############################################################
setAppState = (base, mod, ctx) ->
    log "setAppState"
    if base then appBaseState = base
    if mod then appUIMod = mod
    log "#{appBaseState}:#{appUIMod}"

    uiState.applyUIState(appBaseState, appUIMod, ctx)
    return

############################################################
getCodeFromURL = ->
    log "getCodeFromURL"
    # ##TODO remove: setting code for testing
    # code = "123123"
    # return code

    url = new URL(window.location)
    hash = url.hash

    history.replaceState(history.state, document.title, "/")
    if !hash then return null
    
    code = hash.replace("#", "")
    log code
    return code
    
############################################################
onServiceWorkerMessage = (evnt) ->
    log("  !  onServiceWorkerMessage")
    if typeof evnt.data == "object" and evnt.data.version?
        serviceworkerVersion = evnt.data.version
        # olog { appVersion, serviceworkerVersion }
        if serviceworkerVersion == appVersion then return
        newVersion.textContent = serviceworkerVersion
        menuVersion.classList.add("to-update")
    return

onServiceWorkerSwitch = ->
    # console.log("  !  onServiceWorkerSwitch")
    serviceWorker.controller.postMessage("Hello I am version: #{appVersion}!")
    serviceWorker.controller.postMessage("tellMeVersion")
    return

#endregion

############################################################
#region User Interaction Processes
confirmLogoutProcess = ->
    log "confirmLogoutProcess"
    try
        await logoutModal.userConfirmation()
        account.deleteAccount()
        await logoutRequest()
    catch err then log err
    finally nav.toRoot(true)
    return

#endregion
