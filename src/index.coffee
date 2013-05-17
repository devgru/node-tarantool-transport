OFFSET = # we are talking about uint32 mostly, so step is 4 at most cases
    requestType: 0
    bodyLength : 4
    callbackId : 8 # this is also request id

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
        do @socket.unref
        @socket.on 'data', @dataReceived.bind @
    
    # # response processing # #

    remainder: null
    
    dataReceived: (data) ->
        if @remainder?
            data = Buffer.concat [@remainder, data]
            @remainder = null
        
        loop
            # enough data to read header?
            if data.length < HEADER_LENGTH
                @remainder = data
                break
            
            header = parseHeader data
            responseLength = HEADER_LENGTH + header.bodyLength
            
            # enough data to read body?
            if data.length < responseLength
                @remainder = data
                break
            
            # process this response and, maybe we're done?
            @processResponse header.callbackId, data.slice HEADER_LENGTH, responseLength
            break if data.length is responseLength
            
            # there is more data, loop repeats
            data = data.slice responseLength, data.length
        return
    
    processResponse: (callbackId, body) ->
        if @callbacks[callbackId]?
            @callbacks[callbackId] body
            delete @callbacks[callbackId]
            
            @responsesAwaiting--
            do @socket.unref if @responsesAwaiting is 0
        else
            throw new Error 'trying to call removed callback #' + callbackId
        return
        
    # # requests and callback management # #
    
    callbacks: {}
    
    # each request has its own callback, found by id
    nextCallbackId: 0
    
    registerCallback: (callback) ->
        callbackId = @nextCallbackId
        @callbacks[callbackId] = callback
        
        @responsesAwaiting++
        do @socket.ref if @responsesAwaiting is 1
        
        if callbackId is 4294967295 # tarantool limitation
            @nextCallbackId = 0
        else
            @nextCallbackId++
        
        callbackId # registered
    
    responsesAwaiting: 0
    
    request: (type, body, callback) ->
        header = composeHeader type, body.length, @registerCallback callback
        @socket.write header
        @socket.write body
    
module.exports = TarantoolTransport
