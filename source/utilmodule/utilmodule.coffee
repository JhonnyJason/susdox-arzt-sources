############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("utilmodule")
#endregion

############################################################
import * as tbut from "thingy-byte-utils"

############################################################
charMap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
validAlphanumeKeyCodes = null
validBase32KeyCodes = null
alphaNumRegex = new RegExp('^[a-z0-9]*$')
base32Regex = new RegExp('^[a-km-np-z2-9]*$')

############################################################
argon2Worker = null
argon2HashResolve = null
argon2HashReject = null

############################################################
export initialize = ->
    log "initialize"
    argon2Worker = new Worker("argon2worker.js")
    argon2Worker.addEventListener("message", argon2WorkerResponded)
    prepareValidKeyCodesMap()
    return

############################################################
prepareValidKeyCodesMap = ->
    validAlphanumeKeyCodes = []
    validBase32KeyCodes = []

    for code in [48..57]
        validAlphanumeKeyCodes[code] = true
        if code != 48 and code != 49
            validBase32KeyCodes[code] = true

    # capitalAlpha = code >= 65 && code <= 90
    for code in [65..90]
        validAlphanumeKeyCodes[code] = true

    # smallAlpha = code >= 97 && code <= 122
    for code in [97..122]
        validAlphanumeKeyCodes[code] = true
        if code != 108 and code != 111
            validBase32KeyCodes[code] = true
    return

############################################################
# from - MIT LICENSE Copyright 2011 Jon Leighton - https://gist.github.com/jonleighton/958841 
bufferToBase64 = (buffer) ->
    result = ''

    bytes = new Uint8Array(buffer)
    length = bytes.length

    byteRemainder = length % 3
    mainLength = length - byteRemainder

    # Main loop deals with bytes in chunks of 3
    for i in [0...mainLength] by 3
        # Combine the three bytes into a single integer
        chunk = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]

        # Use bitmasks to extract 6-bit segments from the triplet
        a = (chunk & 16515072) >> 18 # 16515072 = (2^6 - 1) << 18
        b = (chunk & 258048)   >> 12 # 258048   = (2^6 - 1) << 12
        c = (chunk & 4032)     >>  6 # 4032     = (2^6 - 1) << 6
        d = chunk & 63               # 63       = 2^6 - 1

        # Convert the raw binary segments to the appropriate ASCII encoding
        result += charMap[a] + charMap[b] + charMap[c] + charMap[d]

    # Deal with the remaining bytes and padding
    if (byteRemainder == 1)
        chunk = bytes[mainLength]

        a = (chunk & 252) >> 2 # 252 = (2^6 - 1) << 2

        # Set the 4 least significant bits to zero
        b = (chunk & 3)   << 4 # 3   = 2^2 - 1

        result += charMap[a] + charMap[b] + '=='
    
    else if (byteRemainder == 2)
        chunk = (bytes[mainLength] << 8) | bytes[mainLength + 1]

        a = (chunk & 64512) >> 10 # 64512 = (2^6 - 1) << 10
        b = (chunk & 1008)  >>  4 # 1008  = (2^6 - 1) << 4

        # Set the 2 least significant bits to zero
        c = (chunk & 15)    <<  2 # 15    = 2^4 - 1

        result += charMap[a] + charMap[b] + charMap[c] + '='
    
    return result

############################################################
generatePBKDF2SubtleCrypto = (username, pwd) ->
    crypto = window.crypto.subtle
    # log username
    # log pwd    
    saltBytes = tbut.utf8ToBytes(username)
    rawKeyBytes = tbut.utf8ToBytes(pwd)

    keyBytes = await crypto.importKey(
        'raw',
        rawKeyBytes, 
        {name: 'PBKDF2'}, 
        false, 
        ['deriveBits', 'deriveKey']
    )

    derivedKeyObj = await crypto.deriveKey(
        { 
            "name": 'PBKDF2',
            "salt": saltBytes,
            "iterations": 1000,
            # "hash": 'SHA-256'
            "hash": 'SHA-1'
        },
        keyBytes,
        # // Note: we don't actually need a cipher suite,
        # // but the api requires that it must be specified.
        # // For AES the length required to be 128 or 256 bits (not bytes)
        # { "name": 'AES-CBC',"length": 256},
        { 
            "name": 'HMAC', 
            "hash": "SHA-1", 
            "length": 160 
        },
        # Whether or not the key is extractable (less secure) or not (more secure)
        # when false, the key can only be passed as a web crypto object, not inspected
        true,
        # this web crypto object will only be allowed for these functions
        # [ "encrypt", "decrypt" ]
        ["sign", "verify"]
    )

    derivedKeyBytes = await crypto.exportKey("raw", derivedKeyObj)
    derivedKeyBase64 = bufferToBase64(derivedKeyBytes)
    # log derivedKeyBase64
    return derivedKeyBase64

argon2WorkerResponded = (evnt) ->
    log "argon2WorkerResponded"
    if evnt.data? then { error, hashHex } = evnt.data
    # olog { error, hashHex }
    if argon2HashResolve? and hashHex? then return argon2HashResolve(hashHex)
    if argon2HashReject? and error? then return argon2HashReject(error)
    log "argon2Worker response did not cause any effect!"
    return

############################################################
export loginRequestBody = (credentials) ->
    { vpn, username, password } = credentials

    isMedic = true

    if password then hashedPw = await computeHashedPw(vpn, username, password)
    else hashedPw = ""

    pwd = password
    olog { vpn, username, pwd, hashedPw, isMedic }
    return {vpn, username, pwd, hashedPw, isMedic}


export hashedCredentials = (credentials) ->
    { username, code } = credentials

    if !isAlphanumericString(code) then throw new Error("Credentials contained invalid code!")

    if code.length == 8 and (code.indexOf("at")==0) then code = code.slice(2)
    if code.length == 9 or code.length == 6 then hashedPw = await argon2HashPw(code, username)
    else throw new Error("Unexpected code Length!")
    olog { hashedPw, username, dateOfBirth }

    return {username, hashedPw}


############################################################
computeHashedPw = (vpn, username, pwd) ->
    if vpn == 'wfpi'
        if username == 'engi' then return hashUsernamePw(vpn+username, pwd)
        else return hashUsernamePw(username+'.'+vpn, pwd)
    else return hashUsernamePw(username, pwd)

############################################################
export hashUsernamePw = (username, pwd) ->
    alert "#{username} - #{pwd}"
    
    if username.length < 4 then username = username + username + username
    if username.length < 8 then username = username + username

    hash = await generatePBKDF2SubtleCrypto(username, pwd)
    return hash

############################################################
export argon2HashPw = (pin, birthdate) ->
    log "argon2HashPw"
    # if ! argon2Worker then return argon2HashPwLocal()
    promisedHash = new Promise (resolve, reject) ->
        argon2HashResolve = resolve
        argon2HashReject = reject
        return
    
    args = {pin, birthdate}
    argon2Worker.postMessage(args)

    try 
        hashHex = await promisedHash
        # olog { hashHex }
        return hashHex
    catch err
        log "Argon2 threw an Error!"
        log err
    finally
        argon2HashResolve = null
        argon2HashReject = null
    return

############################################################
export isAlphanumericCode = (code) -> validAlphanumeKeyCodes[code]

export isBase32Code = (code) -> validBase32KeyCodes[code]


############################################################
export isAlphanumericString = (string) -> alphaNumRegex.test(string)

export isBase32String = (string) -> base32Regex.test(string) 

############################################################
export waitMS = (timeMS) ->
    return new Promise (resolve, reject) -> setTimeout(resolve, timeMS)

############################################################
export copyToClipboard = (text) ->
    try
        await navigator.clipboard.writeText(text)
        log "Clipboard API succeeded"
        if msgBox? then msgBox.info("Copied: "+text)
        return
    catch err then log err

    ## Oldschool Method
    ## create element to select from
    copyElement = document.createElement("textarea")
    copyElement.value = text
    copyElement.setAttribute("readonly", "")

    #have element available but not visible
    copyElement.style.position = "absolute"
    copyElement.style.left = "-99999px"
    document.body.appendChild(copyElement)
    
    #select text to copy
    document.getSelection().removeAllRanges()
    copyElement.select()
    copyElement.setSelectionRange(0, 99999)
    document.execCommand("copy")

    #remove element again
    document.body.removeChild(copyElement)
    if msgBox? then msgBox.info("Copied: "+text)
    return
