//
//  Utils.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 01/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


enum MethodId: amqp_method_number_t {
    case ConnectionClose   =  655410
    case ConnectionCloseOk =  655411
    case ChannelClose      = 1310760
    case BasicConsume      = 3932181
    case BasicReturn       = 3932210
    case BasicDeliver      = 3932220
    case BasicAck          = 3932240
}


extension String {

    var cstring: UnsafePointer<Int8> {
        return (self as NSString).cStringUsingEncoding(NSUTF8StringEncoding)
    }

    var amqpBytes: amqp_bytes_t {
        return amqp_cstring_bytes(self.cstring)
    }

    init?(amqpBytes: amqp_bytes_t) {
        // need to go via NSString here, the same initialiser for String does not work correctly
        if let s = NSString(bytes: amqpBytes.bytes, length: amqpBytes.len, encoding: NSUTF8StringEncoding) {
            self.init(s)
        } else {
            return nil
        }
    }

}


extension Bool {

    var amqpBoolean: amqp_boolean_t {
        return amqp_boolean_t(UInt(self))
    }

}


extension NSData {

    convenience init(amqpBytes: amqp_bytes_t) {
        self.init(bytes: amqpBytes.bytes, length: amqpBytes.len)
    }

    var amqpBytes: amqp_bytes_t {
        return amqp_bytes_t(len: self.length, bytes: UnsafeMutablePointer<Void>(self.bytes))
    }

}


public enum Response {
    case Success
    case None
    case UnknownLibraryException(String)
    case ConnectionClosed
    case ChannelClosed
    case UnknownServerException
    case Undefined  // catch all for codes that haven't been handled specifically above

    var success: Bool {
        switch self {
        case .Success:
            return true
        default:
            return false
        }
    }
}


func decode(reply: amqp_rpc_reply_t) -> Response {
    switch reply.reply_type.rawValue {
    case AMQP_RESPONSE_NORMAL.rawValue:
        return .Success
    case AMQP_RESPONSE_NONE.rawValue:
        return .None
    case AMQP_RESPONSE_LIBRARY_EXCEPTION.rawValue:
        let error = amqp_error_string2(reply.library_error)
        let s = String(CString: error, encoding: NSUTF8StringEncoding) ?? "undecoded library exception"
        return .UnknownLibraryException(s)
    case AMQP_RESPONSE_SERVER_EXCEPTION.rawValue:
        switch reply.reply.id {
        case MethodId.ConnectionClose.rawValue:
            return .ConnectionClosed
        case MethodId.ChannelClose.rawValue:
            return .ChannelClosed
        default:
            return .UnknownServerException
        }
    default:
        return .Undefined
    }
}


func getResponse(connection: amqp_connection_state_t) -> Response {
    let reply = amqp_get_rpc_reply(connection)
    return decode(reply)
}

