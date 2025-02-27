############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("menumodule")
#endregion

############################################################
import M from "mustache"

############################################################
import * as accountModule from "./accountmodule.js"
import * as pwaInstall from "./pwainstallmodule.js"
import * as triggers from "./navtriggers.js"

############################################################
#region DOM Cache
menuFrame = document.getElementById("menu-frame")
menuAddAccount = document.getElementById("menu-add-account")
menuUserName = document.getElementById("menu-user-name")
menuLogout = document.getElementById("menu-logout")
menuVersion = document.getElementById("menu-version")
menuPWAInstallButton = document.getElementById("menu-pwa-install-button")

#endregion

############################################################
userLabel = menuUserName.getElementsByClassName("menu-label")[0]

############################################################
export initialize = ->
    log "initialize"
    menuFrame.addEventListener("click", menuFrameClicked)
    menuAddAccount.addEventListener("click", addAccountClicked)
    menuLogout.addEventListener("click", logoutClicked)
    menuVersion.addEventListener("click", menuVersionClicked)
    menuPWAInstallButton.addEventListener("click", pwaInstallClicked)
    return

############################################################
#region event Listeners
menuFrameClicked = (evnt) ->
    log "menuFrameClicked"
    triggers.menu(off)
    return

addAccountClicked = (evnt) ->
    log "addAccountClicked"
    evnt.stopPropagation()
    triggers.addAccount()
    return

logoutClicked = (evnt) ->
    log "logoutClicked"
    evnt.stopPropagation()
    triggers.logout()
    return

menuVersionClicked = (evnt) ->
    log "menuVersionClicked"
    evnt.stopPropagation()
    triggers.reload()
    return

pwaInstallClicked = (evnt) ->
    log "pwaInstallClicked"
    pwaInstall.promptForInstallation()
    return

#endregion

############################################################
export updateUser = ->
    log "updateUser"
    try
        credentials = accountModule.getUserCredentials()
        name = credentials.name || credentials.username
        userLabel.textContent = name
        menu.classList.remove("no-user")
    catch err
        log err
        userLabel.textContent = ""
        menu.classList.add("no-user")

    return

############################################################
#region UI State functions

############################################################
export setMenuOff = ->
    document.body.classList.remove("menu-on")
    return

############################################################
export setMenuOn = ->
    document.body.classList.add("menu-on")
    menu.focus()
    return

############################################################
export setInstallableOn =  ->
    document.body.classList.add("installable")

############################################################
export setInstallableOff = ->
    document.body.classList.remove("installable")

#endregion