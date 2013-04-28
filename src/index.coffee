REQUEST_TYPE =
    insert: 13
    select: 17
    update: 19
    delete: 21
    call  : 22
    ping  : 65280

OFFSET = # we are talking about uint32 mostly, so step is 4 at most cases
    requestType: 0
    bodyLength : 4
    callbackId : 8 # yes, this is actually requestId

HEADER_LENGTH = 12

composeHeader = (requestType, bodyLength, callbackId) ->
    header = new Buffer HEADER_LENGTH
    
    header.writeUInt32LE requestType, OFFSET.requestType
    header.writeUInt32LE bodyLength , OFFSET.bodyLength
    header.writeUInt32LE callbackId , OFFSET.callbackId
    
    header # composed
    
parseHeader = (data) ->
    requestType: data.readUInt32LE OFFSET.requestType
    bodyLength : data.readUInt32LE OFFSET.bodyLength
    callbackId : data.readUInt32LE OFFSET.callbackId

class TarantoolTransport
    # lets export some useful constants
    @requestTypes = REQUEST_TYPE
    
    # # header processor # #
    
    processRawResponse: (data) ->
        bytesRead = 0
        console.log 'raw response', data
        loop
            header = parseHeader data.slice bytesRead, bytesRead + HEADER_LENGTH
            bytesRead += HEADER_LENGTH
            
            if header.requestType is REQUEST_TYPE.ping
                returnCode = 0
            else
                returnCode = data.readUInt32LE bytesRead
                bytesRead += 4
                header.bodyLength -= 4 # what is bodyLength, then?
            
            @processResponse header, returnCode, data.slice bytesRead, bytesRead + header.bodyLength
            bytesRead += header.bodyLength
            console.log 'read ' + bytesRead + ' octets of ' + data.length
            break if data.length is bytesRead
        return
    
    processResponse: (header, returnCode, body) ->
        console.log 'response', header, returnCode, body
        
        if @callbacks[header.callbackId]?
            @callbacks[header.callbackId] header, returnCode, body
            delete @callbacks[header.callbackId] # let's prevent memory leak
        else
            console.error 'trying to call removed callback #' + header.callbackId
        return
        
    # # constructor # #
    
    constructor: (host, port, callback) ->
        @socket = (require 'net').connect port, host, callback
        @socket.on 'data', @processRawResponse.bind @
    
    # # request input and callback management # #
    
    callbacks: {}
    
    # each request has its own callback, found by id
    nextCallbackId: 0
    
    
    registerCallback: (callback) ->
        callbackId = @nextCallbackId
        @callbacks[callbackId] = callback
        
        if callbackId is 4294967295 # tarantool limitation
            @nextCallbackId = 0
        else
            @nextCallbackId++
        
        callbackId # registered
    
    
    request: (type, body, callback) ->
        header = composeHeader type, body.length, @registerCallback callback
        console.log 'request', header, body
        @socket.write header
        @socket.write body
    
    
    ping: (callback) -> @request REQUEST_TYPE.ping, (new Buffer 0), callback
    
module.exports = TarantoolTransport
