############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("footermodule")
#endregion

############################################################
import * as radiologistData from "./radiologistdatamodule.js"

############################################################
#region DOM cache

addressDisplay = document.getElementById("address-display")
footer = document.getElementById("footer")

############################################################
footer0 = document.getElementById("display-0")
footer1 = document.getElementById("display-1")
footer2 = document.getElementById("display-2")

############################################################
sustSolAddress = "SustSol GmbH - 8044 Graz, Mariatroster Strasse 378b/7"

#endregion

############################################################
#region internal Variables

footerPosition = 0

############################################################
footerLeft = footer0  
footerShown = footer1
footerRight = footer2

#endregion

############################################################
#region exported Functions

## rotation functions - called by cubemodule
############################################################
export rotateLeft = ->
    addressDisplay.classList.remove("no-transition")
    addressDisplay.classList.remove("position-#{footerPosition}")
    footerPosition++
    addressDisplay.classList.add("position-#{footerPosition}")
    return

export rotateRight = ->
    addressDisplay.classList.remove("no-transition")
    addressDisplay.classList.remove("position-#{footerPosition}")
    footerPosition--
    addressDisplay.classList.add("position-#{footerPosition}")
    return


############################################################
export postRotationCorrection = ->
    log "postRotationCorrection"
    addressDisplay.classList.add("no-transition")
    log "footerPosition: #{footerPosition}"

    addressDisplay.classList.remove("position-#{footerPosition}")
    footerPosition = 0
    addressDisplay.classList.add("position-#{footerPosition}")
    return

## set addresses from outsite - radiologistDataModule
############################################################
export setLeftAddress = (address) ->
    footerLeft.textContent = address
    return

export setShownAddress = (address) ->
    footerShown.textContent = address
    return

export setRightAddress = (address) ->
    footerRight.textContent = address
    return


############################################################
export reset = ->
    log "reset"
    footerPosition = 0
    positionClass = "position-#{footerPosition}"

    setLeftAddress(sustSolAddress)
    setShownAddress(sustSolAddress)
    setRightAddress(sustSolAddress)
    return

export hide = ->
    footer.classList.add("hidden")
    return

export show = ->
    footer.classList.remove("hidden")
    return

#endregion