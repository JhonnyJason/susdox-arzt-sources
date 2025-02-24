############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("footermodule")
#endregion

############################################################
#region DOM cache

addressDisplay = document.getElementById("address-display")
footer = document.getElementById("footer")


############################################################
sustSolAddress = "SustSol GmbH - 8044 Graz, Mariatroster Strasse 378b/7"

#endregion

############################################################
#region exported Functions

export hide = ->
    footer.classList.add("hidden")
    return

export show = ->
    footer.classList.remove("hidden")
    return

#endregion