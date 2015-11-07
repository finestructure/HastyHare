//
//  Queue.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


public class Arguments {
    let arguments: [String: String]
    let entries: UnsafeMutablePointer<amqp_table_entry_t>

    init(arguments: [String: String]) {
        self.arguments = arguments
        self.entries = {
            let n = arguments.count
            let entries = UnsafeMutablePointer<amqp_table_entry_t>.alloc(n)
            var idx = 0
            for (key, val) in arguments {
                var value = amqp_field_value_t()
                set_field_value_bytes(&value, val.amqpBytes)
                let e = amqp_table_entry_t(key: key.amqpBytes, value: value)
                entries[idx++] = e
            }
            return entries
        }()
    }

    var amqpTable: amqp_table_t {
        return amqp_table_t(num_entries: Int32(self.arguments.count), entries: entries)
    }

    deinit {
        self.entries.destroy()
    }
}


public class Queue {

    private let channel: Channel
    public let name: String
    private var _declared = false


    public var declared: Bool {
        return _declared
    }


    init(channel: Channel, name: String, passive: Bool, durable: Bool, exclusive: Bool, autoDelete: Bool) {
        self.channel = channel
        self.name = name
        let args = amqp_empty_table

        amqp_queue_declare(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            passive.amqpBoolean,
            durable.amqpBoolean,
            exclusive.amqpBoolean,
            autoDelete.amqpBoolean,
            args
        )

        self._declared = getReply(self.channel.connection).success
    }


    public func bindToExchange(exchangeName: String, bindingKey: String) -> Bool {
        amqp_queue_bind(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            exchangeName.amqpBytes,
            bindingKey.amqpBytes,
            amqp_empty_table)
        return getReply(self.channel.connection).success
    }


    public func bindToExchange(exchange: Exchange, bindingKey: String) -> Bool {
        return bindToExchange(exchange.name, bindingKey: bindingKey)
    }


    public func bindToExchange(exchangeName: String, arguments: Arguments) -> Bool {
        amqp_queue_bind(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            exchangeName.amqpBytes,
            amqp_empty_bytes,
            arguments.amqpTable
        )
        return getReply(self.channel.connection).success
    }

}

