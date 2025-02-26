############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("tableutils")
#endregion

############################################################
import { Grid, html} from "gridjs"
import { RowSelection } from "gridjs/plugins/selection"
# import { RowSelection } from "gridjs-selection"

import M from "mustache"
import dayjs from "dayjs"
# import { de } from "dayjs/locales"

############################################################
PATIENTID_CELL = 0
ISNEW_CELL = 1
DOBSTANDARD_CELL = 3

############################################################
#region germanLanguage
deDE = {
    search: {
        placeholder: 'Suche...'
    }
    sort: {
        sortAsc: 'Spalte aufsteigend sortieren'
        sortDesc: 'Spalte absteigend sortieren'
    }
    pagination: {
        previous: 'Vorherige'
        next: 'Nächste'
        navigate: (page, pages) -> "Seite #{page} von #{pages}"
        page: (page) -> "Seite #{page}"
        showing: ' '
        of: 'von'
        to: '-'
        results: 'Daten'
    }
    loading: 'Wird geladen...'
    noRecordsFound: 'Es wurden keine Untersuchungen gefunden!'
    # error: 'Beim Abrufen der Daten ist ein Fehler aufgetreten'
    error: " "
}

# deNoRecordsFoundMindateTemplate = "Es wurden keine Untersuchungen ab {{{minDate}}} gefunden!"

#endregion

############################################################
entryBaseURL = "https://www.bilder-befunde.at/webview/index.php?value_dfpk="
messageTarget = null

############################################################
#region sort functions
dateCompare = (el1, el2) ->
    # date1 = dayjs(el1)
    # date2 = dayjs(el2)
    # return -date1.diff(date2)
    
    # here we already expect a dayjs object
    diff = el1.diff(el2)
    if diff > 0 then return 1
    if diff < 0 then return -1
    return 0

numberCompare = (el1, el2) ->
    number1 = parseInt(el1, 10)
    number2 = parseInt(el2, 10)

    if number1 > number2 then return 1
    if number2 > number1 then return -1
    return 0
    # log number1 - number2
    # return number1 - number2

#endregion

############################################################
#region cell formatter functions
isNewFormatter = (content, row) ->
    dotClass = "isNewDot"
    
    if content then dotClass = "isNewDot isNew" 

    innerHTML = "<div class='#{dotClass}'></div>"
    return  html(innerHTML)

bilderFormatter  = (content, row) ->
    return "" unless content?
    # log typeof content
    innerHTML = "<ul class='bilder'>"

    lines = content.split(" : ")
    for line in lines when line.length > 3
        params = line.split(" . ")
        if params.length != 3 then throw new Error("Error in Merged Bilder parameter! '#{content}'")
        # image = {
        #     description: params[0],
        #     url: params[1],
        #     isNew: params[2] == "1"
        # }

        if params[2] == "1"
            innerHTML += "<li><b><a href='#{params[1]}'> #{params[0]}</a></b></li>"
        else
            innerHTML += "<li><a href='#{params[1]}'> #{params[0]}</a></li>"    
        
    innerHTML += "</ul>"
    return html(innerHTML)

befundeFormatter = (content , row) ->
    return "" unless content?
    # log typeof content
    innerHTML = "<ul class='befunde'>"

    lines = content.split(" : ")
    for line in lines when line.length > 3
        params = line.split(" . ")
        if params.length != 3 then throw new Error("Error in Merged Bilder parameter! '#{content}'")
        # befund = {
        #     description: params[0],
        #     url: params[1],
        #     isNew: params[2] == "1"
        # }
        if params[2] == "1"
            innerHTML += "<li><b><a href='#{params[1]}'> #{params[0]}</a></b></li>"
        else
            innerHTML += "<li><a href='#{params[1]}'> #{params[0]}</a></li>"

    innerHTML += "</ul>"
    return html(innerHTML)

documentsFormatter = (content , row) ->
    return "" unless content?
    # log typeof content
    innerHTML = "<ul class='documents'>"

    lines = content.split(" : ")
    for line in lines when line.length > 3
        params = line.split(" . ")
        if params.length != 4 then throw new Error("Error in Merged Bilder parameter! '#{content}'")
        # document = {
        #     description: params[0],
        #     url: params[1],
        #     isNew: params[2] == "1"
        #     type: params[3] == "bild" || "befund"
        # }
        if params[2] == "1"
            innerHTML += "<li class='#{params[3]}'><b><a onclick='window.open(#{params[1]})'> #{params[0]}</a></b></li>"
        else
            innerHTML += "<li class='#{params[3]}'><a href='#{params[1]}'> #{params[0]}</a></li>"

    innerHTML += "</ul>"
    return html(innerHTML)

screeningDateFormatter = (content, row) ->
    return content.format("DD.MM.YYYY")

nameFormatter = (content, row) ->
    linkHTML = """
        <a onclick='selectPatient(#{row._cells[PATIENTID_CELL].data}, "#{content}", "#{row._cells[DOBSTANDARD_CELL].data}")'>#{content}</a>
    """
    if row._cells[ISNEW_CELL].data then return html("<b>#{linkHTML}</b>")
    else return html(linkHTML)

svnFormatter = (content, row) ->
    return content

birthdayFormatter = (content, row) ->
    return content
            
radiologistFormatter = (content, row) ->
    return content

sendingDateFormatter = (content, row) ->
    dateString = content.format("DD.MM.YYYY HH:mm")
    if row._cells[ISNEW_CELL].data then return html("<b>#{dateString}</b>")
    else return dateString 

forwardFormatter = (content, row) ->
    linkHTML = """
        <a href="#{content}" title="Untersuchung weiterleiten" class="forward"><svg width="1.5rem" height="1.5rem" viewBox="0 0 24 24"><path d="M13 9.8V10.7L11.3 10.9C8.7 11.3 6.8 12.3 5.4 13.6C7.1 13.1 8.9 12.8 11 12.8H13V14.1L15.2 12L13 9.8M11 5L18 12L11 19V14.9C6 14.9 2.5 16.5 0 20C1 15 4 10 11 9M17 8V5L24 12L17 19V16L21 12" fill="currentColor"></path></svg></a>
    """
    return html(linkHTML)

sharedToFormatter = (content , row) ->
    return "" unless content?
    # log typeof content
    innerHTML = "<ul class='sharedTo'>"
    existingLines = new Set()

    lines = content.split(" : ").map((el) -> el.trim())
    for line in lines when !existingLines.has(line)        
        innerHTML += "<li>#{line}</li>"
        existingLines.add(line)
        
    innerHTML += "</ul>"
    return html(innerHTML)

#endregion

############################################################
#region exportedFunctions
export getTableHeight = ->
    log "getTableHeight"
    tableWrapper = document.getElementsByClassName("gridjs-wrapper")[0]
    gridJSFooter = document.getElementsByClassName("gridjs-footer")[0]
    headerElement = document.getElementsByTagName("header")[0]

    fullHeight = window.innerHeight
    fullWidth = window.innerWidth
    
    outerPadding = 5


    # nonTableOffset = modecontrols.offsetHeight
    ## we removed the modecontrols
    nonTableOffset = headerElement.offsetHeight
    if !tableWrapper? # table does not exist yet
        # so take the height which should be enough
        nonTableOffset += 114 
    else 
        nonTableOffset += tableWrapper.offsetTop
        nonTableOffset += gridJSFooter.offsetHeight
        nonTableOffset += outerPadding
        log nonTableOffset

    tableHeight = fullHeight - nonTableOffset
    # olog {tableHeight, fullHeight, nonTableOffset, approvalHeight}

    olog {tableHeight}
    return tableHeight

############################################################
#region Definition of columnHeadObjects
patientIdHeadObj = {
    name: ""
    id: "patientId"
    hidden: true
}

studyIdHeadObj = {
    name: ""
    id: "studyId"
    hidden: true
}

isNewHeadObj = {
    name: ""
    id: "isNew"
    formatter: isNewFormatter
    sort: false
}

bilderHeadObj = {
    name: "Bilder"
    id: "images"
    formatter: bilderFormatter
    sort: false
}

befundeHeadObj = {
    name: "Befunde"
    id: "befunde"
    formatter: befundeFormatter
    sort: false
}

documentsHeadObj = {
    name: "Dokumente"
    id: "documents"
    formatter: documentsFormatter
    sort: false
}

screeningDateHeadObj = {
    name: "Unt.-Datum"
    id: "studyDate"
    formatter: screeningDateFormatter
    sort: false
}

nameHeadObj = {
    name: "Name"
    id: "patientFullName"
    formatter: nameFormatter
    sort: false
}

svnHeadObj = {
    name: "SVNR"
    id: "patientSsn"
    formatter: svnFormatter
    sort: false
}

birthdayHeadObj = {
    name: "Geb.-Datum"
    id: "patientDob"
    formatter: birthdayFormatter
    sort: false
}

radiologistHeadObj = {
    name: "Radiologie"
    id: "fromFullName"
    formatter: radiologistFormatter
    sort: false
}

sendingDateHeadObj = {
    name: "Zust.-Datum"
    id: "createdAt"
    formatter: sendingDateFormatter
    sort: false
}

sharedToHeadObj = {
    name: "Berechtigte"
    id: "sharedTo"
    formatter: sharedToFormatter
    sort: false
}


forwardHeadObj = {
    name: ""
    id: "forward"
    plugin: {component: RowSelection}
}

#endregion

export getStandardColumnObjects = (state) ->
    return [patientIdHeadObj, isNewHeadObj, nameHeadObj, birthdayHeadObj]

export getPatientsColumnObjects = (state) ->
    return [studyIdHeadObj, isNewHeadObj, documentsHeadObj, sendingDateHeadObj]

# export getExtendedPatientsColumnObjects = (state) ->
#     return [studyIdHeadObj, isNewHeadObj, befundeHeadObj, bilderHeadObj, screeningDateHeadObj, radiologistHeadObj, sharedToHeadObj, forwardHeadObj]

############################################################
export getLanguageObject = -> return deDE

export getLanguagObjectWithMinDate = (minDate) ->
    newObj = JSON.parse(JSON.stringify(deDE))

    newNoRecordsString = M.render(deNoRecordsFoundMindateTemplate, {minDate})

    newObj.noRecordsFound = newNoRecordsString
    return newObj


#endregion
