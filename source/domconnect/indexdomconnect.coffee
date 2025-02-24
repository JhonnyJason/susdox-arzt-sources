indexdomconnect = {name: "indexdomconnect"}

############################################################
indexdomconnect.initialize = () ->
    global.realBody = document.getElementById("real-body")
    global.footer = document.getElementById("footer")
    global.content = document.getElementById("content")
    global.header = document.getElementById("header")
    global.susdoxLogo = document.getElementById("susdox-logo")
    global.headerInstallButton = document.getElementById("header-install-button")
    global.menuCloseButton = document.getElementById("menu-close-button")
    global.menuButton = document.getElementById("menu-button")
    global.pwainstallHowtoBackground = document.getElementById("pwainstall-howto-background")
    global.logoutmodal = document.getElementById("logoutmodal")
    return
    
module.exports = indexdomconnect