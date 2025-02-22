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
# menuShowQR = document.getElementById("menu-show-qr")
# menuHideQR = document.getElementById("menu-hide-qr")
menuLogout = document.getElementById("menu-logout")
menuVersion = document.getElementById("menu-version")
menuPWAInstallButton = document.getElementById("menu-pwa-install-button")
allUsers = document.getElementById("all-users")
menuEntryTemplate =  document.getElementById("menu-entry-template")
unnamedTextElement = document.getElementById("unnamed-text-element")

#endregion

############################################################
entryTemplate = menuEntryTemplate.innerHTML
unnamedText = unnamedTextElement.textContent

############################################################
export initialize = ->
    log "initialize"
    menuFrame.addEventListener("click", menuFrameClicked)
    menuAddAccount.addEventListener("click", addAccountClicked)
    # menuShowQR.addEventListener("click", showQRClicked)
    # menuHideQR.addEventListener("click", hideQRClicked)
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

userEntryClicked = (evnt) ->
    log "userEntryClicked"
    evnt.stopPropagation()
    el = evnt.currentTarget
    userIndex = el.getAttribute("user-index")
    log userIndex
    {activeAccount} = accountModule.getAccountsInfo()
    userIndex = parseInt(userIndex)

    if userIndex == activeAccount then triggers.home()

    accountModule.setAccountActive(userIndex) unless userIndex == NaN
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
export updateAllUsers = ->
    log "updateAllUsers"
    {activeAccount, allAccounts, accountValidity} = accountModule.getAccountsInfo()
    
    if allAccounts.length == 0 then menu.classList.add("no-user")
    else menu.classList.remove("no-user")
    
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