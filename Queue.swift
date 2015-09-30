//
//  Queue.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


public class Queue {

    internal let connection: amqp_connection_state_t
    internal let channel: amqp_channel_t
    internal let name: String
    internal var _declared = false


    init(connection: amqp_connection_state_t, channel: amqp_channel_t, name: String) {
        self.connection = connection
        self.channel = channel
        self.name = name

        let queue = name.amqpBytes
        let passive: amqp_boolean_t = 0
        let durable: amqp_boolean_t = 1
        let exclusive: amqp_boolean_t = 0
        let auto_delete: amqp_boolean_t = 0
        let args = amqp_empty_table
        let res = amqp_queue_declare(connection, channel, queue, passive, durable, exclusive, auto_delete, args)
        let mem = res.memory.queue.bytes
        let sname = String.fromCString(UnsafePointer<CChar>(mem))
        assert(sname != nil && (sname! == name))

        let reply = amqp_get_rpc_reply(connection)
        if reply.reply_type.rawValue == AMQP_RESPONSE_NORMAL.rawValue {
            self._declared = true
        } else {
            print(errorDescriptionForReply(reply))
        }
    }


    public func bindToExchange(exchange: Exchange, bindingKey: String) -> Bool {
        amqp_queue_bind(
            self.connection,
            self.channel,
            self.name.amqpBytes,
            exchange.name.amqpBytes,
            bindingKey.amqpBytes,
            amqp_empty_table)

        if let error = checkReply(self.connection) {
            print(error)
            return false
        } else {
            return true
        }
    }

}

