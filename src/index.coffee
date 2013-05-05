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
    @connect: (port, host, callback) ->
        socket = (require 'net').connect port, host, callback
        new TarantoolTransport socket
    
    constructor: (@socket) ->
        @socket.on 'data', @processRawResponse.bind @
    
    # # header processor # #

    remainder: null
    
    processRawResponse: (data) ->
        bytesRead = 0
        console.log 'raw response', data
        
        if @remainder?
            data = Buffer.concat [@remainder, data]
            @remainder = null
        
        loop
            # enough data to read header?
            if data.length < HEADER_LENGTH
                @remainder = data.slice bytesRead, data.length
                break
            
            header = parseHeader data.slice bytesRead, bytesRead + HEADER_LENGTH
            
            # enough data to read body?
            if data.length < HEADER_LENGTH + header.bodyLength
                @remainder = data.slice bytesRead, data.length
                break
            
            bytesRead += HEADER_LENGTH
            
            @processResponse header.callbackId, data.slice bytesRead, bytesRead + header.bodyLength
            bytesRead += header.bodyLength
            
            console.log 'read ' + bytesRead + ' octets of ' + data.length
            break if data.length is bytesRead
        console.log 'remainder left', @remainder if @remainder?
        return
    
    processResponse: (callbackId, body) ->
        console.log 'response', callbackId, body
        
        if @callbacks[callbackId]?
            @callbacks[callbackId] body
            delete @callbacks[callbackId] # let's prevent memory leak
        else
            console.error 'trying to call removed callback #' + callbackId
            process.exit 1
        return
        
    # # requests and callback management # #
    
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
    
    end: ->
        @socket.end()
    
module.exports = TarantoolTransport
