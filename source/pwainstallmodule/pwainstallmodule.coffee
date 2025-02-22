############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("pwainstallmodule")
#endregion

############################################################
import * as menu from "./menumodule.js"
import { env } from "./environmentmodule.js"

############################################################
deferredInstallPrompt = null

############################################################
howToToShow = null
appIsInstalled = false

############################################################
# ### Firefox Android HowTo
# - userAgent includes "firefox" and "android"
# ### Firefox Desktop HowTo
# - userAgent include "firefox" but not "android" (Probably it does not matter if Linux, MacOS or Windows)
# ### iOS HowTo
# - Either "ipad", "iphone" or "ipod" in userAgent, or "macintosh" in userAgent with maxTouchPoints > 1
# - On iOS other Apps cannot have "add to Homescreen functionality" ... maybe later
# ### MacOS HowTo
# - "macintosh" in userAgent and maxTouchPoints  = 0

############################################################
export initialize = ->
    log "initialize"
    pwainstallHowtoBackground.addEventListener("click", howtoBackgroundClicked)
    window.addEventListener("beforeinstallprompt", onBeforeInstallPrompt)
    window.addEventListener("appinstalled", onAppInstalled)

    window.matchMedia('(display-mode: standalone)').addEventListener("change",onDisplayModeChange)
 
    # for the case the event is not fired check the state of right  now
    env.inApp = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone

    checkIfInstalled()
    decideOnHowTo()

    setTimeout(showButtonManually, 5000)

    # howToToShow = "ios"
    olog {env, howToToShow, appIsInstalled}
    
    # showDebugInfo()
    return

############################################################
showDebugInfo = ->
    str1 = JSON.stringify(env, null, 4)
    str2 = "howToToShow: #{howToToShow}"
    str3 = window.navigator.userAgent.toLowerCase()
    html = """
    <p>#{str1}</p>
    <p>#{str2}</p>
    <p>#{str3}</p>
    """
    document.getElementById("pwainstall-debug").innerHTML = html
    return 


############################################################
onBeforeInstallPrompt = (e) ->
    log "beforeInstallPrompt"
    e.preventDefault()
    # return

    howToToShow = null
    deferredInstallPrompt = e

    # alert("We received the onBeroferInstallPrompt Event!")
    log "So adding Installbutton ;-)"
    menu.setInstallableOn()    
    return

onAppInstalled = (e) ->
    log "onAppInstalled"
    menu.setInstallableOff()
    deferredInstallPrompt = null    
    return

howtoBackgroundClicked = (evnt) ->
    log "howtoBackgroundClicked"
    log howToToShow
    if howToToShow == "ios" 
        pwainstallHowtoBackground.classList.remove("howto-ios")
        return

    if howToToShow == "mac" 
        pwainstallHowtoBackground.classList.remove("howto-mac")
        return

    if howToToShow == "firefox-android"
        pwainstallHowtoBackground.classList.remove("howto-firefox-android")
        return

    if howToToShow == "firefox-desktop"
        pwainstallHowtoBackground.classList.remove("howto-firefox-desktop")
        return
    return

############################################################
onDisplayModeChange = (evnt) ->
    log "onDisplayModeChange"
    if evnt.matches then env.inApp = true
    else env.inApp = false
    return

############################################################
checkIfInstalled = ->
    log "checkIfInstalled"
    if env.inApp 
        appIsInstalled = true
        return

    # For now we don't check if app exists outside of browser
    # Only if we are "inApp" we donot show the install button 

    # return unless navigator.getInstalledRelatedApps?
    # log "navigator.getInstalledRelatedApps exists"
    
    # results = await navigator.getInstalledRelatedApps()
    # olog results
    # log results.length

    # if Array.isArray(results) and results.length > 0 
    #     appIsInstalled = true   
    return

############################################################
decideOnHowTo = ->
    log "decideOnHowTo"
    
    # TODO remove when we have more HowTos
    #for now we only show HowTos for ios and samsung
    if env.os == "ios"
        howToToShow = "ios"
        return
    else if env.browser == "samsung"
        howToToShow = "samsung"
        return
    else
        howToToShow = null
        return

    ##The real code when we have all HowTos
    if env.os == "android" and env.browser == "firefox"
        howToToShow = "firefox-android"
        return

    if env.os == "android" and env.browser == "samsung"
        howToToShow = "samsung"
        return
    
    if env.os == "ios"
        howToToShow = "ios"
        return

    if env.browser == "firefox"
        howToToShow = "firefox-desktop"
        return
    
    if env.os == "mac"
        howToToShow = "mac"
        return

    return

############################################################
showHowTo = ->
    log "showHowTo"
    log howToToShow
    if howToToShow == "ios" 
        pwainstallHowtoBackground.classList.add("howto-ios")
        return

    if howToToShow == "mac" 
        pwainstallHowtoBackground.classList.add("howto-mac")
        return

    if howToToShow == "firefox-android"
        pwainstallHowtoBackground.classList.add("howto-firefox-android")
        return

    if howToToShow == "firefox-desktop"
        pwainstallHowtoBackground.classList.add("howto-firefox-desktop")
        return

    return

############################################################
showButtonManually = ->
    log "showButtonManually"
    log "appIsInstalled: #{appIsInstalled}"
    return if appIsInstalled
    log "howToToShow: #{howToToShow}"
    return unless howToToShow?
    log "So adding Installbutton ;-)"
    menu.setInstallableOn()
    return


############################################################
export promptForInstallation = ->
    log "promptForInstallation"
    return if appIsInstalled
    if howToToShow? then return showHowTo()
    return unless deferredInstallPrompt?

    try
        # choice = await deferredInstallPrompt.userChoice()
        choiceObject = await deferredInstallPrompt.prompt()
        olog choiceObject
        if choiceObject.outcome == "accepted"
            log "doing installation..."
            menu.setInstallableOff()
            deferredInstallPrompt = null
        else  
            log "doing nothing..."
    return
