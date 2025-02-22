############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("cubemodule")
#endregion

############################################################
import QR from "vanillaqr"

############################################################
import * as radiologistData from "./radiologistdatamodule.js"
import * as address from "./footermodule.js"
import * as codeRequest from "./requestcodeframemodule.js"
import * as account from "./accountmodule.js"
import {qrURLBase} from "./configmodule.js"

############################################################
#region DOM cache

cubeFront = document.getElementById("cube-front")
cubeLeft = document.getElementById("cube-left")
cubeBack = document.getElementById("cube-back")
cubeRight = document.getElementById("cube-right")
cubeTop = document.getElementById("cube-top")

############################################################
sustsolCubeImage = document.getElementById("sustsol-cube-image")
imagesPreloader = document.getElementById("images-preloader")

############################################################
cubeArea = document.getElementById("cube-area")
cubeElement = document.getElementById("cube")

#endregion

############################################################
#region internal Variables

cubePosition = 0

############################################################
currentFront = cubeFront  
currentLeft = cubeLeft
currentBack = cubeBack
currentRight = cubeRight

############################################################
actionAfterRotation = null
transitioning = false
resetting = false
# transitionResolve = null
transitionPromise = null

############################################################
touching = false
# touchStartX = 0
screenWidth = 0 

############################################################
noTouch = true

#endregion


############################################################
export initialize = ->
    log "initialize"
    cube.addEventListener("transitionend", cubeTransitionEnded)
    cube.addEventListener("transitioncancel", cubeTransitionEnded)

    cubeArea.addEventListener("touchstart", touchStarted)
    document.addEventListener("touchend", touchEnded)
    document.addEventListener("touchmove", touchMoved)

    cubeArea.addEventListener("mousedown", mouseDowned)
    document.addEventListener("mouseup", mouseUpped)
    document.addEventListener("mousemove", mouseMoved)

    screenWidth = window.innerWidth
    return




############################################################
getQrElement = ->
    log "getQrElement"
    userCreds = account.getUserCredentials()
    qrURL =  qrURLBase + userCreds.code
    options = 
        url: qrURL
        toTable: false
        ecclevel: 3
        noBorder: true
    console.log("QRURL: "+qrURL)
    currentQr = new QR(options)
    # return currentQr.domElement
    return currentQr.toImage("png")

############################################################
#region Event Listenerscurrent

############################################################
mouseDowned = (evnt) ->
    log "mouseDowned"
    return if noTouch

    # touchStartX = evnt.clientX
    # log touchStartX
    touching = true
    return

touchStarted = (evnt) ->
    log "touchStarted"
    return if noTouch

    return unless evnt.touches.length == 1
    # touchStartX = evnt.touches[0].clientX
    # log touchStartX
    touching = true
    return

############################################################
touchEnded = -> 
    return if noTouch

    if touching then snapBack()
    touching = false
    return

mouseUpped = ->
    return if noTouch

    if touching then snapBack()
    touching = false
    return

############################################################
mouseMoved = (evnt) ->
    return if noTouch

    # log "mouaseMoved"
    return if transitioning
    return unless touching 
    x = evnt.clientX
    # distance = x - touchStartX
    # log distance

    center = 0.5 * screenWidth
    dif = center - x
    
    # log dif
    if dif > 110 then return arrowLeftClicked()
    if dif < -110 then return arrowRightClicked()
    
    tiltDeg = (45.0 * dif) / 110
    addRotationTilt(tiltDeg)
    return

touchMoved = (evnt) ->
    return if noTouch

    # log "touchMoved"
    return if transitioning
    return unless touching
    x = evnt.touches[0].clientX
    # log x
    center = 0.5 * screenWidth
    dif = center - x
    
    # log dif
    if dif > 110 then return arrowLeftClicked()
    if dif < -110 then return arrowRightClicked()
    
    tiltDeg = (45.0 * dif) / 110
    addRotationTilt(tiltDeg)
    return

############################################################
cubeTransitionEnded = (evnt) ->
    log "cubeTransitionEnded"
    if actionAfterRotation? then actionAfterRotation()
    actionAfterRotation = null
    address.postRotationCorrection()
    
    if cubePosition == -1 or cubePosition == 4
        log "cubePosition: #{cubePosition}"
        content.classList.add("no-transition")
        content.classList.remove("position-#{cubePosition}")
        cubePosition = (cubePosition + 4) % 4
        content.classList.add("position-#{cubePosition}")
    
    transitioning = false
    if transitionPromise? then transitionPromise.fullfill()
    transitionPromise = null
    return

############################################################
arrowLeftClicked = (evnt) ->
    log "arrowLeftClicked"
    # olog {
    #     cubePosition,
    #     transitioning,
    #     resetting
    # }
    return if transitioning
    transitioning =  true
    touching = false
    actionAfterRotation = radiologistData.shiftLeft
    rotateLeft()
    return    

############################################################
arrowRightClicked = (evnt) ->
    log "arrowRightClicked"
    # olog {
    #     cubePosition,
    #     transitioning,
    #     resetting
    # }
    return if transitioning
    transitioning = true
    touching = false
    actionAfterRotation = radiologistData.shiftRight    
    rotateRight()
    return

#endregion

############################################################
#region rotation Functions

snapBack = ->
    content.classList.remove("no-transition")
    cubeElement.removeAttribute("style")
    content.classList.add("position-#{cubePosition}")
    return

############################################################
addRotationTilt = (tilt) ->
    log "addRotationTilt"
    switch cubePosition
        when -1 then baseRotation = -90
        when 0 then baseRotation = 0
        when 1 then baseRotation = 90
        when 2 then baseRotation = 180
        when 3 then baseRotation = 270
        when 4 then baseRotation = -360
        else log "cubePosition not in regular range(0-3): #{cubePosition}"
    
    rotation = baseRotation + tilt

    content.classList.add("no-transition")
    cubeElement.style.transform = "scale(0.84) rotateX(180deg) rotateY(#{rotation}deg)"
    return

############################################################
rotateLeft = ->
    content.classList.remove("no-transition")
    cubeElement.removeAttribute("style")
    content.classList.remove("position-#{cubePosition}")
    cubePosition++
    content.classList.add("position-#{cubePosition}")

    temp = currentFront
    currentFront = currentLeft
    currentLeft = currentBack
    currentBack = currentRight
    currentRight = temp

    setCurrentFrontElement(sustsolCubeImage)
    
    address.rotateLeft()
    return

rotateRight = ->
    cubeElement.removeAttribute("style")
    content.classList.remove("no-transition")
    content.classList.remove("position-#{cubePosition}")
    cubePosition--
    content.classList.add("position-#{cubePosition}")

    temp = currentFront
    currentFront = currentRight
    currentRight = currentBack
    currentBack = currentLeft
    currentLeft = temp
    setCurrentFrontElement(sustsolCubeImage)

    address.rotateRight()
    return

#endregion

############################################################
#region exported Functions

export setCurrentFrontElement = (el) ->
    currentFront.replaceChildren(el)
    return

export setCurrentLeftElement = (el) ->
    currentLeft.replaceChildren(el)
    return

export setCurrentBackElement = (el) ->
    currentBack.replaceChildren(el)
    return

export setCurrentRightElement = (el) ->
    currentRight.replaceChildren(el)
    return

############################################################
export setRequestCodeFrame = ->
    log "setRequestCodeFrame"
    setCurrentBackElement(codeRequest.getRequestCodeFrame())
    return

export setPreloader = ->
    log "setPreloader"
    setCurrentBackElement(imagesPreloader)
    return

export setCodeRevealed = ->   
    log "setCodeRevealed"
    qrElement = getQrElement()
    content.classList.remove("no-transition")
    cubeTop.replaceChildren(qrElement)
    return

export reset = ->
    log "reset"
    # olog {
    #     cubePosition,
    #     transitioning,
    #     resetting
    # }
    if resetting then oldResetFinish = actionAfterRotation

    noTouch = true
    positionClass = "position-#{cubePosition}"
    cubePosition = 0

    # finishReset uses positionClass
    ## probably we want to remove the old positionClass
    # cubePosition = 0
    # positionClass = "position-#{cubePosition}"

    currentFront = cubeFront  
    currentLeft = cubeLeft
    currentBack = cubeBack
    currentRight = cubeRight

    setCurrentFrontElement(sustsolCubeImage)
    content.classList.add("position-#{cubePosition}")
    address.reset()

    transitionResolve = null
    transitionPromise = new Promise (resolve) ->
        transitionResolve = resolve
    
    transitionPromise.fullfill = transitionResolve

    finishReset = ->
        log "finishReset"
        if oldResetFinish? then oldResetFinish()
        # olog {positionClass, cubePosition, transitioning, resetting}
        content.classList.remove("no-transition")
        content.classList.remove(positionClass)
        # setCurrentBackElement(imagesPreloader)
        setCurrentLeftElement("")
        setCurrentRightElement("")
        resetting = false

    transitioning = true
    resetting = true
    actionAfterRotation = finishReset

    #security backstop as sometimes the transitionEnd event is not fired
    setTimeout(cubeTransitionEnded, 350)
    return
    
############################################################
export allowTouch = -> noTouch = false

############################################################
export rotateToSustSolLeft = ->
    if transitioning then throw new Error("transitioning")
    transitioning = true
    touching = false
    actionAfterRotation = radiologistData.sustSolRotateCompleted    
    # cubePosition = 0
    rotateRight()
    return

############################################################
export isInTransition = -> transitioning

############################################################
export waitForTransition = -> transitionPromise

#endregion