############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("datamodule")
#endregion

############################################################
import dayjs from "dayjs"

############################################################
import * as utl from "./datautils.js"
import * as S from "./statemodule.js"
import { setUserRole } from "./overviewtablemodule.js"

############################################################
import { requestSharesURL, dataLoadPageSize } from "./configmodule.js"

############################################################
minDate = null
minDateFormatted  = null
patientAuth = null

currentEntryLimit = null

############################################################
allDataPromise = null
patientDataPromise = null

############################################################
dataToShare = null

############################################################
retrieveData = (minDate, patientId) ->
    log "retrieveData #{minDate},#{patientId}"
    try
        pageSize = dataLoadPageSize
        page = 1
        
        receivedCount = 0
        allData = []

        loop
            requestData = {minDate, patientId, page, pageSize}
            log "requesting -> "
            olog requestData

            rawData = await utl.postRequest(requestSharesURL, requestData)
            allData.push(rawData.shareSummary)    
            setUserRole(rawData.roleId)            
        
            # receivedCount = allData.length  
            receivedCount += rawData.currentSharesCount
            if receivedCount == rawData.totalSharesCount then break
            if receivedCount <  pageSize then break
            page++
            
        return utl.groupAndSortByStudyId(allData)
        # if patientId? then return utl.groupAndSortByStudyId(allData)
        # else return utl.groupAndSortByPatientId(allData)

    catch err
        log err
        # return utl.groupAndSortByStudyId(ownSampleData)
        return []

############################################################
export setMinDateDaysBack = (daysCount) ->
    log "setMinDateDaysBack #{daysCount}"
    dateObj = dayjs().subtract(daysCount, "day")
    minDate = dateObj.toJSON()
    minDateFormatted = dateObj.format("DD.MM.YYYY")

    allDataPromise = null
    return

export setMinDateMonthsBack = (monthsCount) ->
    log "setMinDateMonthsBack #{monthsCount}"
    dateObj = dayjs().subtract(monthsCount, "month")
    minDate = dateObj.toJSON()
    minDateFormatted = dateObj.format("DD.MM.YYYY")

    allDataPromise = null
    return

export setMinDateYearsBack = (yearsCount) ->
    log "setMinDateYearsBack #{yearsCount}"
    dateObj = dayjs().subtract(yearsCount, "year")
    minDate = dateObj.toJSON()
    minDateFormatted = dateObj.format("DD.MM.YYYY")

    allDataPromise = null
    return

############################################################
export setEntryLimit = (entryLimit) -> currentEntryLimit = entryLimit
############################################################
export getAllData = ->
    if !allDataPromise? then allDataPromise = retrieveData(minDate, undefined)
    return allDataPromise

export getDataForPatientId = (patientId) ->
    if !patientDataPromise? then patientDataPromise = retrieveData(undefined, patientId)
    return patientDataPromise

############################################################
export invalidatePatientData = ->
    patientDataPromise = null
    return

############################################################
export getMinDate = -> minDateFormatted

############################################################
export standardServerSearchObj = ->
    log "serverSearchObj"
    
    url = (prev, keyword) ->
        if !keyword? or keyword.length < 3 then throw new Error("Stopping request from firing :-)") 
        return "#{prev}?search=#{keyword}"
    return {url}

    # method = "POST"
    # mode = "cors"
    # credentials = "include"
    # headers = {
    #         'Content-Type': 'application/json'
    # }

    # body = {}
    # # body = {minDate, patientId, page, pageSize}

    # handle = (response) ->
    #     log "handle search" 
    #     log response.status
    #     if !response.ok then return null
    #     return response.json()

    # obj = { url, method, mode, credentials, headers, body, handle }

    # obj.then = (data) ->
    #     lof "postprocess search"
    #     # olog data
    #     if data and data.shareSummary then return utl.groupAndSortByStudyId(data.shareSummary)
    #     else return []

    # return obj

############################################################
export standardServerObj = ->
    log "standardServerObj"
    url = requestSharesURL
    method = "POST"
    mode = "cors"
    credentials = "include"
    headers = {
            'Content-Type': 'application/json'
    }
    limit = currentEntryLimit

    # entryLimit = limit
    body = JSON.stringify({limit})
    
    # body = JSON.stringify({entryLimit})
    # body = {minDate, patientId, page, pageSize}

    handle = (response) ->
        log "handle data request" 
        log response.status
        if !response.ok then return null
        return await response.json()

    obj = { url, method, mode, credentials, headers, body, handle }

    obj.then = (data) ->
        log "postprocess data request"
        # olog data
        # return []
        if data? and data.roleId? then setUserRole(data.roleId)            
        if data and data.shareSummary then return utl.groupAndSortByStudyId(data.shareSummary)
        else return []

    return obj