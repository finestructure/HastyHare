//
//  Exchange.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


public class Exchange {

    internal let connection: amqp_connection_state_t
    internal let channel: amqp_channel_t
    internal let name: String
    internal var _declared = false


    init(connection: amqp_connection_state_t, channel: amqp_channel_t, name: String) {
        self.connection = connection
        self.channel = channel
        self.name = name

        let type = "direct"
        let passive: amqp_boolean_t = 0
        let durable: amqp_boolean_t = 0
        let auto_delete: amqp_boolean_t = 0
        let internl: amqp_boolean_t = 0
        let args = amqp_empty_table
        amqp_exchange_declare(
            connection,
            channel,
            name.amqpBytes!, // TODO: avoid ! unwrap
            type.amqpBytes!, // TODO: avoid ! unwrap
            passive,
            durable,
            auto_delete,
            internl,
            args
        )
        let reply = amqp_get_rpc_reply(connection)
        if reply.reply_type.rawValue == AMQP_RESPONSE_NORMAL.rawValue {
            self._declared = true
        } else {
            print(errorDescriptionForReply(reply))
        }
    }


    public func send(message: String, exchange: String = "") -> Bool {
        let ex = exchange.amqpBytes!
        let routing = self.name.amqpBytes!
        let mandatory: amqp_boolean_t = 0
        let immediate: amqp_boolean_t = 0
        let body = message.amqpBytes!
        amqp_basic_publish(self.connection, self.channel, ex, routing, mandatory, immediate, nil, body)
        let reply = amqp_get_rpc_reply(self.connection)
        if reply.reply_type.rawValue == AMQP_RESPONSE_NORMAL.rawValue {
            return true
        } else {
            print(errorDescriptionForReply(reply))
            return false
        }
    }

}