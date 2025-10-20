############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountmodule")
#endregion

############################################################
import * as S from "./statemodule.js"
import * as utl from "./utilmodule.js"
import * as sci from "./scimodule.js"
import { env } from "./environmentmodule.js"
import { AuthenticationError } from "./errormodule.js"
import { specialUserRedirectURL } from "./configmodule.js"

############################################################
noAccount = true
activeAccount = false

requestedCookies = false
cookieTimestamp = undefined

############################################################
export initialize = ->
    log "initialize"
    # fix incompatibility with older versions!
    upgradeAccountStorage()

    if env.isDesktop
        S.save("activeAccount", false, true)
        return

    activeAccount = S.load("activeAccount")

    if !activeAccount? or typeof activeAccount != "object" or !activeAccount.userCredentials?
        noAccount = true
        activeAccount = false
        S.save("activeAccount", false, true)
    else 
        noAccount = false
    return

############################################################
upgradeAccountStorage = ->
    allAccounts = S.load("allAccounts")
    if Array.isArray(allAccounts) then S.remove("allAccounts")

    if Array.isArray(allAccounts) and allAccounts.length > 0
        activeAccount = allAccounts[0]
        S.save("activeAccount", activeAccount, true)

    activeAccount = S.load("activeAccount")
    if typeof activeAccount != "object" 
        S.save("activeAccount", false, true)

    return

############################################################
export getAccountObject = ->
    log "getAccountObject"
    if noAccount then throw new Error("No User Account Available!")

    return activeAccount

export getUserCredentials = ->
    log "getUserCredentials"
    if noAccount then throw new Error("No User Account Available!")

    return activeAccount.userCredentials

export getAccountInfo = ->
    log "getAccountInfo"
    return { activeAccount, requestedCookies, cookieTimestamp }


############################################################
export setCredentials = (credentials) ->
    log "setCredentials"

    activeAccount = {}
    activeAccount.userCredentials = credentials
    activeAccount.loginTimestamp = cookieTimestamp
    noAccount = false
    
    S.save("activeAccount", activeAccount, true) unless env.isDesktop
    return

############################################################
export deleteAccount = ->
    log "deleteAccount"
    if noAccount then throw new Error("No User Account Available!")

    noAccount = true
    activeAccount = false

    requestedCookies = false
    cookieTimestamp = undefined

    S.save("activeAccount", false, true)    
    return
    
############################################################
export assertValidLogin = ->
    if noAccount then throw new Error("No User Account Available!")

    try
        credentials = activeAccount.userCredentials
        log "checking for valid login..."
        olog credentials

        redirectActivation = await utl.checkRedirectActivation(credentials.username)
        
        loginBody = await utl.loginRequestBody(credentials)
        response = await sci.loginRequest(loginBody)

        ## only redirect on correct and successful login :-)
        if redirectActivation then window.location.replace(specialUserRedirectURL)

        requestedCookies = true
        cookieTimestamp = Date.now()

    catch err
        log "Error on assertValidLogin: #{err.message}"
        # only on auth error, we know it is invalid
        # for any non-auth error we act as if it was valid
        if err instanceof AuthenticationError 
            throw new Error("Invalid Credentials!")
    
        requestedCookies = false
        cookieTimestamp = undefined

    return
