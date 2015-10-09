//
//  Queue.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


public class Queue {

    private let connection: amqp_connection_state_t
    private let channel: amqp_channel_t
    internal let name: String
    private var _declared = false


    public var declared: Bool {
        return _declared
    }


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
        let res = amqp_queue_declare(
            connection, channel, queue, passive, durable, exclusive, auto_delete, args
        )

        let sname = String(data: res.memory.queue)
        assert(sname != nil && (sname! == name))
        self._declared = success(connection, printError: true)
    }


    public func bindToExchange(exchange: String, bindingKey: String) -> Bool {
        amqp_queue_bind(
            self.connection,
            self.channel,
            self.name.amqpBytes,
            exchange.amqpBytes,
            bindingKey.amqpBytes,
            amqp_empty_table)
        return success(self.connection, printError: true)
    }

}

