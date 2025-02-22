############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("requestcodeframemodule")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as credentialsFrame from "./credentialsframemodule.js"
import * as account from "./accountmodule.js"
import * as utl from "./utilmodule.js"
import * as sci from "./scimodule.js"
import { acceptButtonClicked } from "./mainbuttonmodule.js"

############################################################
import { NetworkError, InputError, AuthenticationError } from "./errormodule.js"

############################################################
import { ScrollRollDatepicker } from "./scrollrolldatepickermodule.js"

############################################################
#region DOM Cache

requestcodeframeContainer = document.getElementById("requestcodeframe-container")

############################################################
birthdaySlot = document.getElementById("request-birthday-slot")

############################################################
requestPhoneInput = document.getElementById("request-phone-input")
requestBirthdayInput = document.getElementById("request-birthday-input")

############################################################
invalidUserErrorFeedback = document.getElementById("invalid-user-error-feedback")
networkErrorFeedback = document.getElementById("network-error-feedback")
inputErrorFeedback = document.getElementById("input-error-feedback")
requestPreloader = document.getElementById("request-preloader")

############################################################
userFeedback = requestcodeframeContainer.getElementsByClassName("user-feedback")[0]

#endregion

############################################################
birthdayInput = null

datePicker = null
datePickerIsInitialized = false

phoneNumberRegex = /^\+?[0-9]+$/gm

############################################################
export initialize = ->
    log "initialize"
    requestPhoneInput.addEventListener("keydown", requestPhoneInputKeyDowned)
    requestPreloader = requestPreloader.parentNode.removeChild(requestPreloader)

    options =
        element: "request-birthday-input"
        height: 32
    datePicker = new ScrollRollDatepicker(options)

    requestcodeframeContainer = requestcodeframeContainer.parentNode.removeChild(requestcodeframeContainer)
    return

############################################################
requestPhoneInputKeyDowned = (evt) ->
    # log "loginCodeInputKeyDowned"
    # 13 is enter
    if evt.keyCode == 13
        evt.preventDefault()
        acceptButtonClicked()
        return    
    return

############################################################
extractRequestInput = ->
    log "extractRequestInput"
    
    dateOfBirth = datePicker.value
    phoneNumber = requestPhoneInput.value.replaceAll(/[ \-\(\)]/g, "")
    
    olog {phoneNumber, dateOfBirth}

    phoneNumberValid = phoneNumber.length > 6 and phoneNumber.length < 25
    if phoneNumberValid then phoneNumberValid = phoneNumberRegex.test(phoneNumber)

    if !phoneNumberValid then throw new InputError("Fehler in der Telefonnummer!")
    if !dateOfBirth then throw new InputError("Kein Geburtsdatum gewählt!")

    userFeedback.innerHTML = requestPreloader.innerHTML
    return {dateOfBirth, phoneNumber}


############################################################
makeAcceptable = ->
    log "makeAcceptable"
    if datePicker.isOn then datePicker.acceptCurrentPositions()
    if datePicker.isOn then return false
    return true

############################################################
export getBirthdayValue = ->
    log "getBirthdayValue"
    return datePicker.value

export requestCode = ->
    log "requestCode"
    try
        acceptable = makeAcceptable() # checks for acceptable datepicker state
        if !acceptable then return 

        resetAllErrorFeedback()
        requestObj = await extractRequestInput() 

        olog requestObj
        response = await sci.requestCode(requestObj)
        # if response? then nav.toBaseAt("add-account", null, 1)

        nav.toBaseAt("add-account", null, 1)
    catch err
        log err
        errorFeedback(err)
    return

############################################################
export getRequestCodeFrame = ->
    log "getRequestCodeFrame"
    return requestcodeframeContainer

############################################################
export resetAllErrorFeedback = ->
    log "resetAllErrorFeedback"
    userFeedback.innerHTML = ""
    requestcodeframeContainer.classList.remove("error")
    return

############################################################
errorFeedback = (error) ->
    log "errorFeedback"

    if error instanceof NetworkError
        requestcodeframeContainer.classList.add("error")
        userFeedback.innerHTML = networkErrorFeedback.innerHTML
        return
    
    if error instanceof InputError
        requestcodeframeContainer.classList.add("error")
        userFeedback.innerHTML = inputErrorFeedback.innerHTML
        return

    if error instanceof AuthenticationError
        requestcodeframeContainer.classList.add("error")
        userFeedback.innerHTML = invalidUserErrorFeedback.innerHTML
        return

    requestcodeframeContainer.classList.add("error")
    userFeedback.innerHTML = "Unexptected Error occured!"
    return


############################################################
#region UI States handles
export prepareForRequest = ->
    log "prepareForRequest"
    resetAllErrorFeedback()
    if !datePickerIsInitialized ## because the element was not in DOM it was not initialized before
        datePicker.initialize() 
        datePickerIsInitialized = true
    

    dateOfBirth = credentialsFrame.getBirthdayValue()
    log dateOfBirth
    if dateOfBirth? and dateOfBirth then datePicker.setValue(dateOfBirth)
    else datePicker.reset()
    return

export prepareForUpdateRequest = ->
    log "prepareForUpdateRequest"
    resetAllErrorFeedback()
    if !datePickerIsInitialized ## because the element was not in DOM it was not initialized before
        datePicker.initialize() 
        datePickerIsInitialized = true
    
    accountToUpdate = account.getAccountObject()
    # olog accountToUpdate
    
    datePicker.setValue(accountToUpdate.userCredentials.dateOfBirth)
    datePicker.freeze()
    return

############################################################
export reset = ->
    resetAllErrorFeedback()
    requestPhoneInput.value = ""
    if datePickerIsInitialized then datePicker.reset()
    requestBirthdayInput.value = ""
    return

#endregion