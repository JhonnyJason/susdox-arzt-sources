############################################################
export class NetworkError extends Error
    constructor: (message) ->
        super(message)
        @name = "NetworkError"

############################################################
export class InputError extends Error
    constructor: (message) ->
        super(message)
        @name = "InputError"

############################################################
export class AuthenticationError extends Error
    constructor: (message) ->
        super(message)
        @name = "AuthenticationError"
