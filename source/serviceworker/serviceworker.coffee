import { appVersion } from "./configmodule.js"

############################################################
log = (arg) -> console.log("[serviceworker] #{arg}")

############################################################
appCacheName = "ARZT-PWA_app"
fontCacheName = "ARZT-PWA_fonts"


############################################################
# This is for the case we need to delete - usually we reuse QRcch_app and update "/" on a new install without deleting everything
# We need to delete the cache if there is an outdated and unused file which would stay in the cache otherwise
cachesToDelete = [ ]

############################################################
fixedAppFiles = [
    "/"
    "/argon2worker.js"
    "/manifest.json"
    "/img/icon.png"
    "/img/sustsol_logo.png"
    "/img/document_certificate.png"
    "/img/icon_bild.gif"
]

optionalAppFiles = [
    "/apple-touch-icon.png"
    "/favicon.svg"
    "/favicon.ico"
    "/favicon-96x96.png"
    "/web-app-manifest-192x192.png"
    "/web-app-manifest-512x512.png"
]

############################################################
fontEndings = /.(o|t)tf$|.woff2?$/ # for otf,ttf,woff and woff2

############################################################
urlMatchOptions = {
    ignoreSearch: true
}

############################################################
onRegister = ->
    # ## prod-c log "onRegister"
    # #uncomment for production - comment for testing
    self.addEventListener('activate', activateEventHandler)
    self.addEventListener('fetch', fetchEventHandler)
    self.addEventListener('install', installEventHandler)
    # # # #end uncomment for production
    self.addEventListener('message', messageEventHandler)

    # clients = await self.clients.matchAll({ includeUncontrolled: true })
    # message = "postRegister"
    # client.postMessage(message) for client in clients  

    # ## prod-c log "postRegister: found #{clients.length} clients!"
    return

############################################################
#region Event Handlers
activateEventHandler = (evnt) ->
    # ## prod-c log "activateEventHandler"
    evnt.waitUntil(self.clients.claim())
    # ## prod-c log "clients have been claimed!"
    return

 
fetchEventHandler = (evnt) -> 
    # ## prod-c log "fetchEventHandler"
    # log evnt.request.url
    return unless evnt.request.method == "GET"
    evnt.respondWith(cacheThenNetwork(evnt.request))
    return

installEventHandler = (evnt) -> 
    # ## prod-c log "installEventHandler"
    self.skipWaiting()
    # ## prod-c log "skipped waiting :-)"
    evnt.waitUntil(installAppCache())
    return

messageEventHandler = (evnt) ->
    ## prod-c log "messageEventHandler"
    ## prod-c log "typeof data is #{typeof evnt.data}"
    # log JSON.stringify(evnt.data, null, 4)
    ## prod-c log "I am version #{appVersion}!"

    # Commands to be executed
    if evnt.data == "v?" or evnt.data == "tellMeVersion"
        # get all available windows and tell them the Version
        clients = await self.clients.matchAll({includeUncontrolled: true})
        message = {version: appVersion}
        client.postMessage(message) for client in clients
    
    return

#endregion

############################################################
#region helper functions
installAppCache = ->
    # ## prod-c log "installAppCache"
    try
        await deleteCaches(cachesToDelete)
        cache = await caches.open(appCacheName)
        return cache.addAll(fixedAppFiles)
    catch err then ## prod-c log "Error on installAppCache: #{err.message}"
    return

cacheThenNetwork = (request) ->
    # ## prod-c log "cacheThenNetwork"
    try cacheResponse = await caches.match(request, urlMatchOptions)
    catch err then log err
    if cacheResponse? then return cacheResponse
    else return handleCacheMiss(request)
    return

############################################################
deleteCaches = (cacheNames) ->
    # ## prod-c log "deleteCaches"
    prms = []
    prms.push(caches.delete(name)) for name in cacheNames
    try return await Promise.all(prms)
    catch err then ## prod-c log "Error in deleteCaches: #{err.message}"
    return  
    

############################################################
handleCacheMiss = (request) ->
    # ## prod-c log "handleCacheMiss"
    url = new URL(request.url)
    if isOptionalAppFile(url.pathname) then return handleAppFileMiss(request)
    if fontEndings.test(url.pathname) then return handleFontMiss(request)
    return fetch(request)
    
############################################################
handleAppFileMiss = (request) ->
    # ## prod-c log "handleAppFileMiss"
    # log request.url
    try return await fetchAndCache(request, appCacheName)
    catch err then ## prod-c log "Error on handleAppFileMiss: #{err.message}"
    return

handleFontMiss = (request) ->
    # ## prod-c log "handleFontMiss"
    # log request.url
    try return await fetchAndCache(request, fontCacheName)
    catch err then ## prod-c log "Error on fontImageMiss: #{err.message}"
    return

############################################################
fetchAndCache = (request, cacheName) ->
    cache = await caches.open(cacheName)
    response = await fetch(request) 
    cache.put(request, response.clone())
    return response

############################################################
isOptionalAppFile = (pathname) ->
    # ## prod-c log "isOptionalAppFile"
    # log pathname
    if optionalAppFiles.includes(pathname) then return true
    else return false
    return
    
#endregion


############################################################
onRegister()