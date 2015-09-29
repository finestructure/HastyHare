//
//  Connection.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 29/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


extension String {

    func toMQStr() -> [CChar]? {
        return self.cStringUsingEncoding(NSUTF8StringEncoding)
    }

}


func errorDescriptionForReply(reply: amqp_rpc_reply_t) -> String {
    return ""
}


public class Connection {

    private let connection: amqp_connection_state_t
    private let socket: COpaquePointer
    private var _connected = false
    private var _loggedIn = false


    public var connected: Bool {
        return _connected
    }


    public var loggedIn: Bool {
        return _loggedIn
    }


    public init(host: String, port: Int) {
        self.connection = amqp_new_connection()
        self.socket = amqp_tcp_socket_new(self.connection)
        let status = amqp_socket_open(self.socket, host.toMQStr()!, Int32(port))
        self._connected = (status == AMQP_STATUS_OK.rawValue)
    }


    public func login(username: String, password: String, vhost: String = "/") {
        if self.connected {
            let channel_max: Int32 = 0
            let frame_max: Int32 = 131072 // 128kB
            let heartbeat: Int32 = 0
            let sasl_method = AMQP_SASL_METHOD_PLAIN
            let reply = amqp_login_with_credentials(
                self.connection,
                vhost.toMQStr()!,
                channel_max,
                frame_max,
                heartbeat,
                sasl_method,
                username.toMQStr()!,
                password.toMQStr()!
            )
            if reply.reply_type.rawValue == AMQP_RESPONSE_NORMAL.rawValue {
                self._loggedIn = true
            } else {
                errorDescriptionForReply(reply)
            }
        }
    }

}
