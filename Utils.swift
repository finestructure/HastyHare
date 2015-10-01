//
//  Utils.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 01/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


enum MethodId: amqp_method_number_t {
    case ConnectionClose = 655410
    case ChannelClose = 1310760
}


extension String {

    func toMQStr() -> UnsafePointer<Int8> {
        return (self as NSString).cStringUsingEncoding(NSUTF8StringEncoding)
    }


    var amqpBytes: amqp_bytes_t {
        return amqp_cstring_bytes(self.toMQStr())
    }


    init?(MQStr: UnsafePointer<Int8>) {
        self.init(CString: MQStr, encoding: NSUTF8StringEncoding)
    }

}


func errorDescriptionForReply(reply: amqp_rpc_reply_t) -> String {
    switch reply.reply_type.rawValue {
    case AMQP_RESPONSE_NONE.rawValue:
        return "reply type 'none'"
    case AMQP_RESPONSE_LIBRARY_EXCEPTION.rawValue:
        let error = amqp_error_string2(reply.library_error)
        return String(MQStr: error) ?? "Unknow library error"
    case AMQP_RESPONSE_SERVER_EXCEPTION.rawValue:
        switch reply.reply.id {
        case MethodId.ConnectionClose.rawValue:
            return "Server exception: connection closed"
        case MethodId.ChannelClose.rawValue:
            return "Server exception: channel closed"
        default:
            return "Unknown server exception"
        }
    default:
        return "no error"
    }
}


typealias Error = String


func replyToError(reply: amqp_rpc_reply_t) -> Error? {
    if reply.reply_type.rawValue == AMQP_RESPONSE_NORMAL.rawValue {
        return nil
    } else {
        return errorDescriptionForReply(reply)
    }
}


func success(connection: amqp_connection_state_t, printError: Bool = false) -> Bool {
    let reply = amqp_get_rpc_reply(connection)
    if let error = replyToError(reply) {
        if printError {
            print(error)
        }
        return false
    } else {
        return true
    }
}


func success(reply: amqp_rpc_reply_t, printError: Bool = false) -> Bool {
    if let error = replyToError(reply) {
        if printError {
            print(error)
        }
        return false
    } else {
        return true
    }
}
