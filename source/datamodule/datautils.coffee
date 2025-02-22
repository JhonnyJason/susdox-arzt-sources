############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("datautils")
#endregion

############################################################
import dayjs from "dayjs"

############################################################
import { requestSharesURL, dataLoadPageSize } from "./configmodule.js"

############################################################
StudyToEntry = {}
PatientToEntry = {}

############################################################
#region merge Properties Functions
mergeIsNew = (obj, share) ->
    shareIsNew = share.isNew? and share.isNew and share.isNew != false
    return obj.isNew or shareIsNew

mergePatientId = (obj, share) ->
    return share.patientId

mergeStudyDate = (obj, share) ->
    current = obj.studyDate
    niu = dayjs(share.studyDate)
    if !current? then return niu

    # use the newer date
    diff = current.diff(niu)
    if diff < 0 then return niu
    else return current

mergeStudyId = (obj, share) ->
    return ""

mergePatientFullname = (obj, share) ->
    current = obj.patientFullName
    niu = share.patientFullName
    if !current? then return niu
    
    # just checking if everything is in order
    if current != niu then log "patientFullName not matching. "+current+" vs "+niu
    
    return current

mergePatientSsn = (obj, share) ->
    current = obj.patientSsn
    niu = share.patientSsn
    if !current? then return niu

    # just checking if everything is in order
    if current != niu then log "patientSsn not matching. "+current+" vs "+niu+" @(studyId:#{share.studyId} | patientId:#{share.patientId})"

    return current

mergePatientDob = (obj, share) ->
    currentString = obj.patientDob
    niu = dayjs(share.patientDob)
    niuString = niu.format("DD.MM.YYYY")
    if !currentString? then return niuString

    # just checking if everything is in order
    if niuString != currentString then log "patientDob not matching. "+currentString+" vs "+niuString+" @(studyId:#{share.studyId} | patientId:#{share.patientId})"

    return currentString

mergeCreatedBy = (obj, share) ->
    current = obj.fromFullName
    niu = share.fromFullName
    if !current? then return niu
    else return current
    # merged = current + " |\n\n" + niu
    # return merged

mergeDateCreated = (obj, share) ->
    current = obj.createdAt
    niu = dayjs(share.createdAt)
    if !current? then return niu

    #use the newer date
    diff = current.diff(niu)
    if diff < 0 then return niu
    else return current

mergeBefunde = (obj, share) ->
    result = obj.befunde
    result = "" unless result?
    return result unless share.documentUrl?

    if !(share.formatType == 4 or share.formatType == "4")
        if share.isNew? and share.isNew and share.isNew != "false" then isNew = 1 
        else isNew = 0
        result += "#{share.documentDescription} . #{share.documentUrl} . #{isNew} : "

    return result

mergeImages = (obj, share) ->
    result = obj.images
    result = "" unless result?
    return result unless share.documentUrl?

    if (share.formatType == 4 or share.formatType == "4")
        if share.isNew? and share.isNew and share.isNew != "false" then isNew = 1 
        else isNew = 0
        result += "#{share.documentDescription} . #{share.documentUrl} . #{isNew} : "

    return result

mergeDocuments = (obj, share) ->
    result = obj.documents
    result = "" unless result?
    return result unless share.documentUrl?

    if share.isNew? and share.isNew and share.isNew != "false" then isNew = 1 
    else isNew = 0

    if (share.formatType == 4 or share.formatType == "4")
        result += "#{share.documentDescription} . #{share.documentUrl} . #{isNew} . bild : "
    else
        result += "#{share.documentDescription} . #{share.documentUrl} . #{isNew} . befund : "

    return result

mergeSharedTo = (obj, share) ->
    result = obj.sharedTo || ""
    return result unless share.toFullName? 
    addedString = ""

    if Array.isArray(share.toFullName) then addedString = share.toFullName.join(" : ")
    else if typeof share.toFullName == "string" then addedString = share.toFullName
    
    if result.length > 0 and addedString.length > 0 then return "#{result} : #{addedString}"
    
    if result.length > 0 then return result
    
    return addedString


mergeForward = (obj, share) ->
    # result = obj.forward
    return "#{location.origin}/webview/viewer/forward.php?studyId=#{share.studyId}"


#endregion

############################################################
defaultSharesCompare = (el1, el2) ->
    date1 = dayjs(el1.createdAt)
    date2 = dayjs(el2.createdAt)
    return -date1.diff(date2)
    # return date1.diff(date2)

patientSharesCompare = (el1, el2) ->
    date1 = dayjs(el1.studyDate)
    date2 = dayjs(el2.studyDate)
    return -date1.diff(date2)
    # return date1.diff(date2)

############################################################
groudByStudyId = (data) ->
    ## TODO improve caching of Cases
    ## Because maybe the next cases added would fit to a previous case

    StudyToEntry = {}

    before = performance.now()
    for d in data
        entry = {}
        entry[d.shareId] = d
        oldEntry = StudyToEntry[d.studyId]
        StudyToEntry[d.studyId] = Object.assign(entry, oldEntry)
    
    results = []
    for key,entry of StudyToEntry
        obj = {}
        for shareId,share of entry
            obj.isNew = mergeIsNew(obj, share)
            # obj.studyDate = mergeStudyDate(obj, share)
            obj.patientId = mergePatientId(obj, share)
            obj.patientFullName = mergePatientFullname(obj, share)
            # obj.patientSsn = mergePatientSsn(obj, share)
            obj.patientDob = mergePatientDob(obj, share)
            # obj.studyDescription = mergeStudyDescription(obj, share)
            # obj.fromFullName = mergeCreatedBy(obj, share)
            obj.createdAt = mergeDateCreated(obj, share)
            obj.documents = mergeDocuments(obj,share)
            # obj.befunde = mergeBefunde(obj,share)
            # obj.images = mergeImages(obj,share)
            # obj.forward = mergeForward(obj,share)
            # obj.sharedTo = mergeSharedTo(obj, share)
            obj.select = false
            obj.studyId = key
            obj.index = results.length
        results.push(obj)

    after = performance.now()
    diff = after - before
    log "mapping took: "+diff+"ms"
    
    return results

groudByPatientId = (data) ->
    ## TODO improve caching of Cases
    ## Because maybe the next cases added would fit to a previous case

    PatientToEntry = {}

    before = performance.now()
    for d in data
        entry = {}
        entry[d.shareId] = d
        oldEntry = PatientToEntry[d.patientId]
        PatientToEntry[d.patientId] = Object.assign(entry, oldEntry)
    
    results = []
    for key,entry of PatientToEntry
        obj = {}
        for shareId,share of entry
            obj.isNew = mergeIsNew(obj, share)
            # obj.studyDate = mergeStudyDate(obj, share)
            obj.studyId = mergeStudyId(obj, share)
            obj.patientFullName = mergePatientFullname(obj, share)
            # obj.patientSsn = mergePatientSsn(obj, share)
            obj.patientDob = mergePatientDob(obj, share)
            # obj.studyDescription = mergeStudyDescription(obj, share)
            # obj.fromFullName = mergeCreatedBy(obj, share)
            obj.createdAt = mergeDateCreated(obj, share)
            obj.documents = mergeDocuments(obj,share)
            # obj.befunde = mergeBefunde(obj,share)
            # obj.images = mergeImages(obj,share)
            obj.select = false
            obj.patientId = key
            obj.index = results.length
        results.push(obj)

    after = performance.now()
    diff = after - before
    log "mapping took: "+diff+"ms"
    
    return results

############################################################
# this function is called, when doctor looks at the patientTable
export groupAndSortByStudyId = (rawData) ->
    allData = groudByStudyId(rawData.flat())
    return allData.sort(defaultSharesCompare)
    # return allData.sort(patientSharesCompare)

# this function is called when doctor looks at the default Table
export groupAndSortByPatientId = (rawData) ->
    allData = groudByPatientId(rawData.flat())
    return allData.sort(defaultSharesCompare)
    
############################################################
export postRequest = (url, data) ->
    options =
        method: 'POST'
        mode: 'cors'
        credentials: 'include'

        body: JSON.stringify(data)
        headers:
            'Content-Type': 'application/json'

    try
        response = await fetch(url, options)
        if !response.ok then throw new Error("Response not ok - status: "+response.status+"!")
        return response.json()
    catch err then throw new Error("Network Error: "+err.message)
