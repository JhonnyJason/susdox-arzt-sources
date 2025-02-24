############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("cubemodule")
#endregion

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
screenWidth = 0 

############################################################
noTouch = true

#endregion


############################################################
export initialize = ->
    log "initialize"
    cube.addEventListener("transitionend", cubeTransitionEnded)
    cube.addEventListener("transitioncancel", cubeTransitionEnded)

    screenWidth = window.innerWidth
    return

############################################################
cubeTransitionEnded = (evnt) ->
    log "cubeTransitionEnded"
    if actionAfterRotation? then actionAfterRotation()
    actionAfterRotation = null
    
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
export setPreloader = ->
    log "setPreloader"
    setCurrentBackElement(imagesPreloader)
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
    
#endregion