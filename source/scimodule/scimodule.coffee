############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("scimodule")
#endregion

############################################################
import * as utl from "./utilmodule.js"
import { NetworkError, AuthenticationError } from "./errormodule.js"

import { loginURL, logoutURL } from "./configmodule.js"

############################################################
export loginRequest = (body) ->
    method = "POST"
    mode = 'cors'
    credentials = "include"

    headers = { 'Content-Type': 'application/json' }
    body = JSON.stringify(body)
    
    fetchOptions = { method, mode, credentials, headers, body }

    # log "loginRequest"
    # olog body
    # olog fetchOptions

    try
        console.log(loginURL)        
    
        response = await fetch(loginURL, fetchOptions)
        console.log(response.status)
    
        # if response.ok then return await response.text()
        ## TODO: use json from response
        if response.ok then return await response.json()
        
        error = new Error("#{await response.text()}")
        error.status = response.status
        throw error
    catch err
        if err.status == 401 then throw new AuthenticationError(err.message)
        throw new NetworkError("#{err.message}. Code: #{err.status}")
    return

export logoutRequest = ->
    method = "POST"
    mode = 'cors'
    credentials = "include"
    
    fetchOptions = { method, mode, credentials }

    try    
        response = await fetch(logoutURL, fetchOptions)
        console.log(response.status)
    
        if response.ok then return await response.json()
        
        error = new Error("#{await response.text()}")
        error.status = response.status
        throw error
    catch err
        if err.status == 401 then throw new AuthenticationError(err.message)
        throw new NetworkError("#{err.message}. Code: #{err.status}")
    return
