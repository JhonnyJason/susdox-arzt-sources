############################################################
export dataEndpointURL =  "https://www.bilder-befunde.at/pwa-api/api/v1/data/" # parameter -> geb + code
export screeningsEndpointURL = "https://www.bilder-befunde.at/pwa-api/api/v1/studies/" # parameter -> geb + code
# export loginURL = "https://www.bilder-befunde.at/pwa-api/api/v1/credentials/"
export loginURL = "https://www.bilder-befunde.at/pwa-api/api/v1/login/"
export codeRequestURL = "https://www.bilder-befunde.at/pwa-api/api/v1/request-code/"

export desktopLoginURL = "https://www.bilder-befunde.at/pwa-api/api/v1/desktop-login/"

export appVersion = "v0.0.2"


# TODO integrate
export requestSharesURL = "https://www.bilder-befunde.at/pwa-api/api/v1/cockpit/shares/"
export forwardBaseURL = "#{location.origin}/webview/viewer/forward.php?"
 
export dataLoadPageSize = 1000
export tableRenderCycleMS = 200
export searchDebounceMS = 1100