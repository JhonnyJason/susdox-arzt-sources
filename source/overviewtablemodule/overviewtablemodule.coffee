############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("overviewtablemodule")
#endregion

############################################################
import { Grid, html} from "gridjs"
import dayjs from "dayjs"
# import { de } from "dayjs/locales"

############################################################
import * as triggers from "./navtriggers.js"

############################################################
import * as utl from "./tableutils.js"
import * as header from "./tableheadermodule.js"
import * as dataModule from "./datamodule.js"
import { searchDebounceMS, forwardBaseURL } from "./configmodule.js"

############################################################
#region DOM Cache
gridjsFrame = document.getElementById("gridjs-frame")

#endregion

############################################################
tableObj = null
currentTableHeight = 0
############################################################
updateLater = null
navigatingBack = false

############################################################
patientId = null
forwardingHRef = ""

############################################################
gridJSSearch = null
rootStyle = null

############################################################
userRole = 3 # 1 admin, 2 radiologist, 3 doctor
useExtendedPatientTable = false

############################################################
instantSearchLocked = false
currentKeyword = null
nextSearch = null


############################################################
enteredDefaultState = false

############################################################
export initialize = ->
    log "initialize"
    window.addEventListener("resize", updateTableHeight)
    window.gridSearchByString = gridSearchByString
    window.selectPatient = selectPatient
    rootObj = document.querySelector(':root')
    rootStyle = rootObj.style
    return

instantSearch = (keyword) ->
    return if keyword.length < 3 

    nextSearch = null
    if instantSearchLocked and keyword != currentKeyword then nextSearch = () -> instantSearch(keyword)
    if instantSearchLocked then return
    instantSearchLocked = true

    log "instantSearch"
    columns = utl.getStandardColumnObjects()
    server = dataModule.standardServerObj()

    ##patch handle to exit correctly
    handleResponse = server.handle

    patchedResponseHandle = (response) ->
        error = null
        try result = await handleResponse(response)
        catch err then error = err

        instantSearchLocked = false
        if nextSearch? then nextSearch()
        
        if error? then throw error
        return result

    server.handle = patchedResponseHandle


    language = utl.getLanguageObject()

    search = {
        server: dataModule.standardServerSearchObj()
        debounceTimeout: searchDebounceMS        
        keyword: keyword
    }

    pagination = { limit: 50 }
    sort = false
    fixedHeader = true
    resizable = false

    gridJSOptions = { columns, server, language, search, pagination, sort, fixedHeader, resizable }
    
    height = "#{utl.getTableHeight()}px"
    rootStyle.setProperty("--table-max-height", height)

    range = getSearchFocusRange()

    if tableObj?
        tableObj = null
        gridjsFrame.innerHTML = ""  
        tableObj = new Grid(gridJSOptions)
        await tableObj.render(gridjsFrame).forceRender()
        # render alone does not work here - it seems the Old State still remains in the GridJS singleton thus a render here does not refresh the table at all
    else
        tableObj = new Grid(gridJSOptions)
        gridjsFrame.innerHTML = ""    
        await tableObj.render(gridjsFrame)
    
    gridJSSearchInput = document.getElementsByClassName("gridjs-search-input")[0]
    if gridJSSearchInput? 
        gridJSSearchInput.addEventListener("keydown", gridJSSearchInputKeyDowned)
        setSearchFocusRange(range, keyword)
    
    return


############################################################
renderTable = (dataPromise) ->
    log "renderTable"

    columns = utl.getStandardColumnObjects()
    server = dataModule.standardServerObj()

    language = utl.getLanguageObject()
    search = {
        server: dataModule.standardServerSearchObj()
        debounceTimeout: searchDebounceMS
    }

    pagination = { limit: 50 }
    sort = false
    fixedHeader = true
    resizable = false
    height = "#{utl.getTableHeight()}px"
    rootStyle.setProperty("--table-max-height", height)
    width = "100%"
    
    autoWidth = false
    
    gridJSOptions = { columns, server, language, search, pagination, sort, fixedHeader, resizable }

    if tableObj?
        tableObj = null
        gridjsFrame.innerHTML = ""  
        tableObj = new Grid(gridJSOptions)
        await tableObj.render(gridjsFrame).forceRender()
        # render alone does not work here - it seems the Old State still remains in the GridJS singleton thus a render here does not refresh the table at all
    else
        tableObj = new Grid(gridJSOptions)
        gridjsFrame.innerHTML = ""    
        await tableObj.render(gridjsFrame)
    
    gridJSSearchInput = document.getElementsByClassName("gridjs-search-input")[0]
    if gridJSSearchInput?
        gridJSSearchInput.addEventListener("keydown", gridJSSearchInputKeyDowned)
        # gridJSSearchInput.focus()
    return

############################################################
renderPatientTable = (dataPromise) ->
    log "renderPatientTable"
    
    columns = utl.getPatientsColumnObjects()
    data = -> dataPromise
    language = utl.getLanguageObject()
    search = true

    pagination = { limit: 50 }
    sort = false
    fixedHeader = true
    resizable = false
    
    height = "#{utl.getTableHeight()}px"
    rootStyle.setProperty("--table-max-height", height)

    width = "100%"
    
    autoWidth = false
    
    gridJSOptions = { columns, data, language, search, pagination, sort, fixedHeader, resizable }
    
    if tableObj?
        tableObj = null
        gridjsFrame.innerHTML = ""  
        tableObj = new Grid(gridJSOptions)
        await tableObj.render(gridjsFrame).forceRender()
        # render alone does not work here - it seems the Old State still remains in the GridJS singleton thus a render here does not refresh the table at all
    else
        tableObj = new Grid(gridJSOptions)
        gridjsFrame.innerHTML = ""    
        await tableObj.render(gridjsFrame)
        
    gridJSSearch = document.getElementsByClassName("gridjs-search")[0]
    gridJSSearch.addEventListener("animationend", searchPositionMoved)
    return

############################################################
updateTableHeight = (height) ->
    log "updateTableHeight"
    olog { height }

    if typeof height != "number" then height = utl.getTableHeight()
    if currentTableHeight == height then return
    currentTableHeight = height 
    height = height+"px"
    rootStyle.setProperty("--table-max-height", height)
    return

############################################################
updateTable = (config) ->
    log "updateTable"
    olog {rendering, updateLater}
    if rendering  
        updateLater = () -> updateTable(config)
        return

    rendering = true
    try await tableObj.updateConfig(config).forceRender()
    catch err then log err
    rendering = false
    
    if updateLater?
        log "updateLater existed!"
        updateNow = updateLater
        updateLater = null
        updateNow()
    log "update done!"
    return

############################################################
getSearchFocusRange = ->
    searchInput = document.getElementsByClassName("gridjs-search-input")[0]
    return null unless searchInput? and searchInput == document.activeElement
    start = searchInput.selectionStart
    end = searchInput.selectionEnd
    return {start, end}

setSearchFocusRange = (range,keyword) ->
    { start, end } = range
    searchInput = document.getElementsByClassName("gridjs-search-input")[0]
    return unless searchInput?
    
    olog {range}
    log searchInput.value
    if searchInput.value == "" then searchInput.value = keyword
    log searchInput.value


    searchInput.setSelectionRange(start, end)
    searchInput.focus()
    return


############################################################
searchPositionMoved = ->
    log "searchPositionMoved"
    if navigatingBack
        navigatingBack = false
        setDefaultState()
    else
        gridJSSearchInput = document.getElementsByClassName("gridjs-search-input")[0]
        if gridJSSearchInput? then gridJSSearchInput.focus()
    return


############################################################
gridSearchByString = (name) ->
    log "gridSearchByString #{name}"
    search = {keyword: name}
    updateTable({search})
    return

selectPatient = (selectedPatientId, selectedPatientName, selectedDateOfBirth) ->
    log "selectPatient #{selectedPatientId},#{selectedPatientName},#{selectedDateOfBirth}"

    ctx = { selectedPatientId, selectedPatientName, selectedDateOfBirth }
    olog ctx
    triggers.patientSelect(ctx)
    return
    

############################################################
gridJSSearchInputKeyDowned = (evnt) ->
    log "gridJSSearchInputKeyDowned"
    if (evnt.key == 'Enter' or evnt.keyCode == 13) then instantSearch(this.value)
    return
############################################################
checkUserRole = ->
    log "checkUserRole"
    # oneway switch only
    return if useExtendedPatientTable 

    useExtendedPatientTable = (userRole == 1) or (userRole == 2)
    return

############################################################
export setUserRole = (role) ->
    userRole = role
    return

############################################################
export refresh = ->
    log "refresh"
    setDefaultState()
    return 

export startPatientSearch = ->
    overviewtable.classList.add("search")
    gridJSSearchInput = document.getElementsByClassName("gridjs-search-input")[0]
    if gridJSSearchInput? then gridJSSearchInput.focus()
    return

export cancelPatientSearch = ->
    overviewtable.classList.remove("search")
    gridJSSearchInput = document.getElementsByClassName("gridjs-search-input")[0]
    if gridJSSearchInput? then gridJSSearchInput.blur()
    return


############################################################
#region set to state Functions
export setDefaultState = ->
    log "setDefaultState"
    return if enteredDefaultState
    enteredDefaultState = true

    dataModule.invalidatePatientData()
    overviewtable.classList.remove("patient-table")
    overviewtable.classList.remove("search")
    
    renderTable()
    return

export setPatientSelectedState = ->
    log "setPatientSelectedState"
    overviewtable.classList.add("patient-table")
    checkUserRole()
    if useExtendedPatientTable then overviewtable.classList.add("privileged")

    dataPromise = dataModule.getDataForPatientId(patientId)
    renderPatientTable(dataPromise)
    return


export setPatient = (ctx) ->
    log "setPatient"
    enteredDefaultState = false

    olog ctx

    { selectedPatientId, selectedPatientName, selectedDateOfBirth } = ctx

    patientId = selectedPatientId
    header.indicatePatient(selectedPatientName, selectedDateOfBirth)
    setPatientSelectedState()
    return

export unsetPatient =  ->
    log "unsetPatient"
    enteredDefaultState = false
    
    dataModule.invalidatePatientData()
    overviewtable.classList.remove("patient-table")
    overviewtable.classList.remove("search")
    
    patientID = null
    return

#endregion