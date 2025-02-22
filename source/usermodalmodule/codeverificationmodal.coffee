############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("codeverificationmodule")
#endregion

############################################################
import * as sci from "./scimodule.js"
import * as utl from "./utilmodule.js"
import { ModalCore } from "./modalcore.js"

############################################################
import { NetworkError, InputError, AuthenticationError } from "./errormodule.js"

############################################################
import { ScrollRollDatepicker } from "./scrollrolldatepickermodule.js"

############################################################
#region DOM Cache
codeverificationContent = codeverificationmodal.getElementsByClassName("modal-content")[0]

############################################################
# codeverificationBirthdayInput = document.getElementById("codeverification-birthday-input")

############################################################
invalidTokenErrorFeedback = document.getElementById("invalid-token-error-feedback")
expiredTokenErrorFeedback = document.getElementById("expired-token-error-feedback")
networkErrorFeedback = document.getElementById("network-error-feedback")
inputErrorFeedback = document.getElementById("confirmation-error-feedback")
confirmationPreloader = document.getElementById("confirmation-preloader")

############################################################
userFeedback = document.getElementById("codeverification-user-feedback")
confirmButton = document.getElementById("codeverification-confirm-button")

#endregion

############################################################
#region Internal Variables
code = ""
promiseConsumed = false

############################################################
datePicker = null
core = null

#endregion

############################################################
export initialize = ->
    log "initialize"
    core = new ModalCore(codeverificationmodal)
    core.connectDefaultElements()
    # confirm button is not default modal element
    confirmButton.addEventListener("click", confirmButtonClicked)
    
    element = "codeverification-birthday-input"
    datePicker = new ScrollRollDatepicker({element})
    await datePicker.initialize()
    
    # olog datePicker
    return

############################################################
#region Internal Functions
makeAcceptable = ->
    log "makeAcceptable"
    if datePicker.isOn then datePicker.acceptCurrentPositions()
    if datePicker.isOn then return false
    return true

############################################################
confirmButtonClicked = ->
    log "confirmButtonClicked"
    confirmButton.classList.add("disabled")
    try
        if !makeAcceptable() then return
        resetAllErrorFeedback()
        userFeedback.innerHTML = confirmationPreloader.innerHTML
        # dateOfBirth = codeverificationBirthdayInput.value
        dateOfBirth = datePicker.value
        if !dateOfBirth then throw new InputError("No dateOfBirth provided!")
        
        credentials = {code, dateOfBirth}
        olog credentials
        loginBody = await utl.loginRequestBody(credentials)
        response = await sci.loginRequest(loginBody)
        if response? and response.name? then credentials.name = response.name 
        log response

        resetAllErrorFeedback()
        core.accept(credentials)
    catch err then errorFeedback(err)
    finally confirmButton.classList.remove("disabled")
    return

############################################################
errorFeedback = (error) ->
    log "errorFeedback"
    log error

    # NetworkError, InputError, ValidationError, ExpiredTokenError, InvalidTokenError

    if error instanceof NetworkError
        codeverificationContent.classList.add("error")
        userFeedback.innerHTML = networkErrorFeedback.innerHTML
        return

    if error instanceof InputError
        codeverificationContent.classList.add("error")
        codeverificationBirthdayInput.classList.add("error")
        userFeedback.innerHTML = inputErrorFeedback.innerHTML
        return

    if error instanceof AuthenticationError
        codeverificationContent.classList.add("error")
        codeverificationBirthdayInput.classList.add("error")
        userFeedback.innerHTML = inputErrorFeedback.innerHTML
        return

    codeverificationContent.classList.add("error")
    userFeedback.innerHTML = "Unexptected Error occured!"
    return

############################################################
resetAllErrorFeedback = ->
    log "resetAllErrorFeedback"
    codeverificationContent.classList.remove("error")
    codeverificationBirthdayInput.classList.remove("error")
    userFeedback.innerHTML = ""
    return

#endregion

############################################################
export pickUpConfirmedCredentials = (givenCode) ->
    log "pickUpConfirmedCredentials"
    code = givenCode
    promiseConsumed = true
    return core.modalPromise

############################################################
#region UI State Manipulation

export turnUpModal =  ->
    log "turnUpModal"
    return if core.modalPromise? # already up

    promiseConsumed = false
    core.activate()
    return

export turnDownModal = (reason) ->
    log "turnDownModal"
    if core.modalPromise? and !promiseConsumed 
        core.modalPromise.catch(()->return)
        # core.modalPromise.catch((err) -> log("unconsumed: #{err}"))

    core.reject(reason)
    promiseConsumed = false
    resetAllErrorFeedback()
    return

#endregion