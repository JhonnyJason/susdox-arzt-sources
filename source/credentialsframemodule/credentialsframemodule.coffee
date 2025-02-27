############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("credentialsframemodule")
#endregion

############################################################
import * as nav from "navhandler"

############################################################
import * as account from "./accountmodule.js"
import * as utl from "./utilmodule.js"
import * as sci from "./scimodule.js"
import { acceptButtonClicked } from "./mainbuttonmodule.js"

############################################################
import { NetworkError, InputError, AuthenticationError } from "./errormodule.js"

############################################################
#region DOM Cache
credentialsframeContainer = document.getElementById("credentialsframe-container")

############################################################
loginVPNInput = document.getElementById("login-vpn-input")
loginPasswordInput = document.getElementById("login-password-input")
loginUsernameInput = document.getElementById("login-username-input")

############################################################
invalidUserErrorFeedback = document.getElementById("invalid-user-error-feedback")
networkErrorFeedback = document.getElementById("network-error-feedback")
inputErrorFeedback = document.getElementById("input-error-feedback")
loginPreloader = document.getElementById("login-preloader")

############################################################
userFeedback = credentialsframeContainer.getElementsByClassName("user-feedback")[0]

#endregion

############################################################
accountToUpdate = null

############################################################
export initialize = ->
    log "initialize"
    loginPreloader = loginPreloader.parentNode.removeChild(loginPreloader)

    loginUsernameInput.addEventListener("keydown", loginUsernameInputKeyDowned)

    loginPasswordInput.addEventListener("keydown", loginPasswordInputKeyDowned)

    # focusInput = -> this.focus()
    # loginVPNInput.addEventListener("click", focusInput)
    # loginUsernameInput.addEventListener("click", focusInput)
    # loginPasswordInput.addEventListener("click", focusInput)

    return

############################################################
loginPasswordInputKeyDowned = (evt) ->
    # 13 is enter
    if evt.keyCode == 13
        evt.preventDefault()
        acceptButtonClicked()
        return    
    return

############################################################
loginUsernameInputKeyDowned = (evt) ->
    # 13 is enter
    if evt.keyCode == 13
        evt.preventDefault()
        loginPasswordInput.focus()
        return    
    return

############################################################
extractCredentials = ->
    log "extractCredentials"
    vpn = loginVPNInput.value.toLowerCase()
    vpn = vpn.trim()
    # TODO check if vpn is valid - ignoring for now

    username = loginUsernameInput.value.toLowerCase()
    username = username.trim()
    if !username then throw new InputError("Kein Benutzername eingegeben!")

    password = loginPasswordInput.value
    password = password.trim()

    credentials = { vpn, username, password }
    userFeedback.innerHTML = loginPreloader.innerHTML

    log "credentials: "
    olog credentials

    try
        loginBody = await utl.loginRequestBody(credentials)
        response = await sci.loginRequest(loginBody)
        if response? and response.name? then credentials.name = response.name
        alert("Received Name: #{credentials.name}")
    catch err then throw err
    
    return credentials

############################################################
export getBirthdayValue = ->
    log "getBirthdayValue"
    return datePicker.value

export isUpdate = -> return accountToUpdate?

############################################################
export acceptInput = ->
    log "acceptInput"
    try
        resetAllErrorFeedback()
        credentials = await extractCredentials() # also checks if they are valid
        
        if accountToUpdate? 
            # we just updated an account - update credentials and save
            accountToUpdate.userCredentials = credentials
            account.saveAllAccounts()

        else account.addValidAccount(credentials)
            
        # update or adding an account succeeded - so back to root :-)
        await nav.toRoot(true) 
    catch err
        log err
        errorFeedback(err)
    return

############################################################
export resetAllErrorFeedback = ->
    log "resetAllErrorFeedback"
    userFeedback.innerHTML = ""
    credentialsframeContainer.classList.remove("error")
    return

############################################################
errorFeedback = (error) ->
    log "errorFeedback"

    if error instanceof NetworkError
        credentialsframeContainer.classList.add("error")
        userFeedback.innerHTML = networkErrorFeedback.innerHTML
        return
    
    if error instanceof InputError
        credentialsframeContainer.classList.add("error")
        userFeedback.innerHTML = inputErrorFeedback.innerHTML
        return

    if error instanceof AuthenticationError
        credentialsframeContainer.classList.add("error")
        userFeedback.innerHTML = invalidUserErrorFeedback.innerHTML
        return

    credentialsframeContainer.classList.add("error")
    userFeedback.innerHTML = "Unexptected Error occured!"
    return


############################################################
#region UI States handles
export prepareForCodeUpdate = ->
    log "prepareForCodeUpdate"
    resetAllErrorFeedback()
    accountToUpdate = account.getAccountObject()
    # olog accountToUpdate

    # TODO adjust to    
    # datePicker.setValue(accountToUpdate.userCredentials.dateOfBirth)
    # datePicker.freeze()
    return

############################################################
export prepareForAddCode = ->
    log "prepareForAddCode"
    resetAllErrorFeedback()
    accountToUpdate = null
    loginUsernameInput.value = ""
    loginPasswordInput.value = ""
    return

############################################################
export reset = ->
    log "reset"
    resetAllErrorFeedback()
    accountToUpdate = null
    loginUsernameInput.value = ""
    loginPasswordInput.value = ""
    return


#endregion