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

    private let channel: Channel
    internal let name: String
    private var _declared = false


    public var declared: Bool {
        return _declared
    }


    init(channel: Channel, name: String) {
        self.channel = channel
        self.name = name

        let queue = name.amqpBytes
        let passive: amqp_boolean_t = 0
        let durable: amqp_boolean_t = 1
        let exclusive: amqp_boolean_t = 0
        let auto_delete: amqp_boolean_t = 0
        let args = amqp_empty_table
        let res = amqp_queue_declare(
            self.channel.connection, self.channel.channel, queue, passive, durable, exclusive, auto_delete, args
        )

        let sname = String(data: res.memory.queue)
        assert(sname != nil && (sname! == name))
        self._declared = success(self.channel.connection, printError: true)
    }


    public func bindToExchange(exchangeName: String, bindingKey: String) -> Bool {
        amqp_queue_bind(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            exchangeName.amqpBytes,
            bindingKey.amqpBytes,
            amqp_empty_table)
        return success(self.channel.connection, printError: true)
    }


    public func bindToExchange(exchange: Exchange, bindingKey: String) -> Bool {
        return bindToExchange(exchange.name, bindingKey: bindingKey)
    }

}

