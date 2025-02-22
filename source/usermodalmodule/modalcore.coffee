############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("modalcore")
#endregion

############################################################
export class ModalCore
    constructor: (@modalElement) ->
        @modalPromise = null
        @rejectPromise = null
        @acceptPromise = null
        if !@modalElement? then @modalElement = null
        @accept = @accept.bind(this)
        @reject = @reject.bind(this)

    assignElement: (el) -> @modalElement = el
    
    connectDefaultElements: ->
        self = this
        clickCatcher = @modalElement.getElementsByClassName("click-catcher")[0]
        closeButton = @modalElement.getElementsByClassName("modal-close-button")[0]
        acceptButton = @modalElement.getElementsByClassName("modal-accept-button")[0]
        cancelButton = @modalElement.getElementsByClassName("modal-cancel-button")[0]
        if clickCatcher? then clickCatcher.addEventListener("click", () -> self.reject("click-catcher"))
        if closeButton? then closeButton.addEventListener("click", () -> self.reject("modal-close-button"))
        if acceptButton? then acceptButton.addEventListener("click", () -> self.accept("modal-accept-button"))
        if cancelButton? then cancelButton.addEventListener("click", () -> self.reject("modal-cancel-button"))
        return

    reject: (arg) ->
        arg = arg || "Default Modal Reject"
        reject = @rejectPromise
        @rejectPromise = null
        @acceptPromise = null
        @modalPromise = null
        @modalElement.classList.remove("shown")
        if reject? then reject(arg)
        return
    
    accept: (arg) ->
        arg = arg || "Default Modal Accept"
        resolve = @acceptPromise
        @rejectPromise = null
        @acceptPromise = null
        @modalPromise = null
        @modalElement.classList.remove("shown")
        if resolve? then resolve(arg)
        return

    activate: ->
        return if @modalPromise?
        core = this
        @modalPromise = new Promise (resolve, reject) ->
            core.rejectPromise = reject
            core.acceptPromise = resolve
    
        @modalElement.classList.add("shown")
        return
