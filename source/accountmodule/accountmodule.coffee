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

############################################################
activeAccount = NaN
allAccounts = []
accountValidity = []

noAccount = true

############################################################
export initialize = ->
    log "initialize"
    if env.isDesktop
        S.save("allAccounts", [], true)
        S.save("activeAccount", NaN)
        return

    allAccounts = S.load("allAccounts") || []
    S.save("allAccounts", allAccounts, true)
    activeAccount = parseInt(S.load("activeAccount"))
    # olog { allAccounts, activeAccount }
    return unless allAccounts.length > 0

    noAccount = false
    return

############################################################
export getAccountObject = (index) ->
    log "getAccountObject"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")
    return allAccounts[index]

export getUserCredentials = (index) ->
    log "getUserCredentials"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    accountObj = allAccounts[index]
    return accountObj.userCredentials

export getRadiologistImages = (index) ->
    log "getRadiologistImages"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    accountObj = allAccounts[index]
    
    # olog accountObj

    return accountObj.radiologistImages

export getRadiologistAddresses = (index) ->
    log "getRadiologistAddresses"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    accountObj = allAccounts[index]
    
    # olog accountObj

    return accountObj.radiologistAddresses


export getAccountsInfo = ->
    log "getAccountsInfo"
    return { activeAccount, allAccounts, accountValidity }

############################################################
findExistingAccount = (credentials) ->
    log "findExistingAccount"
    newCredString = JSON.stringify(credentials)
    for account,index in allAccounts
        credString = JSON.stringify(account.userCredentials)
        if credString == newCredString then return index 
    return null

############################################################
export addValidAccount = (credentials) ->
    log "addValidAccount"
    # we set it as active by default
    accountIndex = addNewAccount(credentials)
    setAccountActive(accountIndex)
    setAccountValid(accountIndex)
    return

############################################################
export addNewAccount = (credentials) ->
    log "addNewAccount"
    name = credentials.name
    if name? then delete credentials["name"]

    accountIndex = findExistingAccount(credentials)
    if accountIndex? then return accountIndex

    accountIndex = allAccounts.length
    accountObj = {}
    accountObj.userCredentials = credentials
    accountObj.radiologistImages = []
    accountObj.radiologistAddresses = []    
    # accountObj.label = "Benutzer #{accountIndex + 1}"
    accountObj.label = ""
    accountObj.name = name
    allAccounts.push(accountObj)
    S.save("allAccounts") unless env.isDesktop
    noAccount = false
    return accountIndex

export setAccountActive = (index) ->
    log "setAccountActive"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    activeAccount = index

    if env.isDesktop then S.set("activeAccount", index)
    else S.save("activeAccount", index)
    return

export setAccountValid = (index) ->
    log "setAccountValid"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    accountValidity[index] = true
    return

export accountIsValid = (index) ->
    # return false ## for testing
    log "accountIsValid"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    if typeof accountValidity[index] == "boolean"
        return accountValidity[index]

    throw new Error("Account validity has not been set yet!")
    return

export deleteAccount = (index) ->
    log "deleteAccount"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    deleteCurrentAccount = index == activeAccount
    activeAccountWasZero = activeAccount == 0

    allAccounts.splice(index, 1)
    accountValidity.splice(index, 1)

    if allAccounts.length == 0
        noAccount = true
        activeAccount = NaN
        if env.isDesktop
            S.set("activeAccount", NaN)
        else
            S.save("activeAccount", NaN)
            S.save("allAccounts")
        return

    if deleteCurrentAccount and activeAccountWasZero
        S.save("allAccounts") unless env.isDesktop
        S.callOutChange("activeAccount")

    if deleteCurrentAccount and !activeAccountWasZero
        S.save("allAccounts") unless env.isDesktop
        activeAccount--

        if env.isDesktop then S.set("activeAccount", activeAccount)
        else S.save("activeAccount", activeAccount)

    if !deleteCurrentAccount and index < activeAccount
        activeAccount--
        if env.isDesktop
            S.setSilently("activeAccount", activeAccount)
        else
            S.saveSilently("activeAccount", activeAccount)
    return

export saveAllAccounts = -> S.save("allAccounts") unless env.isDesktop
    
############################################################
export saveLabelEdit = (label, index) ->
    log "saveLabelEdit"
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    accountObj = allAccounts[index]
    accountObj.label = label
    S.save("allAccounts") unless env.isDesktop
    return

############################################################
export assertValidLogin = (index) ->
    if noAccount then throw new Error("No User Account Available!")
    if !index? then index = activeAccount
    if index >= allAccounts.length then throw new Error("No account by index: #{index}")

    # validity is equlivalent to: we already logged-in this session
    if typeof accountValidity[index] == "boolean" && accountValidity[index]
        return

    accountObj = allAccounts[index]

    try
        credentials = accountObj.userCredentials
        loginBody = await utl.loginRequestBody(credentials)
        response = await sci.loginRequest(loginBody)
        accountValidity[index] = true

    catch err
        log "Error on assertValidLogin: #{err.message}"
        # only on auth error, we know it is invalid
        # for any non-auth error we act as if it was valid
        if err instanceof AuthenticationError 
            accountValidity[index] = false
        else 
            accountValidity[index] = true

    return
