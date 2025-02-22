############################################################
export env = {
    os: "other", browser: "other", inApp: false, 
    isMobile: false, isDesktop: false
}

############################################################
# check for hints that we are inside of a PWA
if window.matchMedia('(display-mode: standalone)').matches
    env.inApp = true
if window.matchMedia('(installed: yes)').matches
    env.inApp = true

if document.referrer.startsWith('android-app://') 
    env.inApp = true

if navigator.standalone then env.inApp = true

############################################################
# Check for hints about OS and Browser
userAgent = window.navigator.userAgent.toLowerCase()

containsFirefox = userAgent.indexOf("firefox") > -1 
containsSafari = userAgent.indexOf("safari") > -1
containsChrome = userAgent.indexOf("chrome") > -1
containsCRIOS = userAgent.indexOf("crios") > -1
containsOPR = userAgent.indexOf("opr") > -1
containsAndroid = userAgent.indexOf("android") > -1 
containsMacintosh = userAgent.indexOf("macintosh") > -1
containsMac = userAgent.indexOf("mac") > -1
containsIPhone = userAgent.indexOf("iphone") > -1
containsIPad = userAgent.indexOf("ipad") > -1
containsWin = userAgent.indexOf("win") > -1
multiTouch = navigator.maxTouchPoints > 1

isLandscape = window.innerHeight < window.innerWidth

############################################################
# detect OS
if containsIPhone or containsIPad or (containsMacintosh and multiTouch) 
    # (containsMacintosh and multiTouch) = iPad OS 13
    env.os = "ios"
    env.isMobile = true
    env.isDesktop = false
else if containsMac and !(containsMacintosh and multiTouch)
    env.os = "mac"
    env.isMobile = false
    env.isDesktop = true  
else if containsAndroid
    env.os = "android"
    env.isMobile = true
    env.isDesktop = false
else if containsWin
    env.os = "windows"
    env.isMobile = false
    env.isDesktop = true
else if !multiTouch or isLandscape
    env.os = "other"
    env.isMobile = false
    env.isDesktop = true
else 
    env.os = "other"
    env.isMobile = true
    env.isDesktop = false


############################################################
# detect Browser
if containsFirefox then env.browser = "firefox"
if containsOPR then env.browser = "opera"
else if containsChrome and containsSafari then env.browser = "chrome"
else if containsCRIOS and containsSafari then env.browser = "chrome"
else if containsSafari then env.browser = "safari"
else env.browser = "other"

############################################################
# console.log(env)


console.log("For Debugging - setting isDesktop false..")
env.isDesktop = false