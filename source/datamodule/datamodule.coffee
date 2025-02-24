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
currentEntryLimit = null #? Set it to something?

############################################################
patientDataPromise = null

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
export getDataForPatientId = (patientId) ->
    if !patientDataPromise? then patientDataPromise = retrieveData(undefined, patientId)
    return patientDataPromise

############################################################
export invalidatePatientData = ->
    patientDataPromise = null
    return

############################################################
export standardServerSearchObj = ->
    log "serverSearchObj"
    
    url = (prev, keyword) ->
        if !keyword? or keyword.length < 3 then throw new Error("Stopping request from firing :-)") 
        return "#{prev}?search=#{keyword}"
    return {url}

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
    body = JSON.stringify({limit})
    
    handle = (response) ->
        log "handle data request" 
        log response.status
        if !response.ok then return null
        return await response.json()

    obj = { url, method, mode, credentials, headers, body, handle }

    obj.then = (data) ->
        log "postprocess data request"
        dataString = JSON.stringify(data, null, 4)
        if data? and data.roleId? then setUserRole(data.roleId)            
        if data and data.shareSummary then return utl.groupAndSortByStudyId(data.shareSummary)
        else return []

    return obj