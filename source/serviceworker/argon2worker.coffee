############################################################
#region debug
import { createLogFunctions, debugOn } from "thingy-debug"
{log, olog} = createLogFunctions("argon2worker")
debugOn("argon2worker")
#endregion

import libsodium from "libsodium-wrappers-sumo"
import { bytesToHex } from "thingy-byte-utils"
sodium = null

initialize = ->
    # log("Argon2 Worker is here!")
    addEventListener("message", handleMessage)
    await libsodium.ready
    sodium = libsodium
    return

calculateArgon2 = (pin,birthdate) ->
    # log "calculateArgon2"
    salt = birthdate + "SUSDOX"
    # olog {pin, salt}
    hash = sodium.crypto_pwhash(
        32,        # Output size in bytes
        pin,       # Will be converted to a UTF-8 Uint8Array by sodium.js
        salt,      # Dito
        1,         # Number of hash iterations
        67108864,  # Use 64MB memory
        sodium.crypto_pwhash_ALG_ARGON2ID13	# Hash algorithm: argon2id
    )
    # log "finished calculation!"
    hashHex = bytesToHex(hash)
    return hashHex


handleMessage = (evnt) ->
    # log("argon2Worker received a message!")
    { pin, birthdate } = evnt.data
    # olog evnt.data

    if !pin? or !birthdate? then postMessage({error:"Invalid Arguments!"})
    try 
        if !sodium? then await libsodium.ready
    
        hashHex = calculateArgon2(pin, birthdate)
        postMessage({hashHex})
    catch err then postMessage({error:err.message})
    return


initialize()