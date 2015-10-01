//
//  Channel.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


public typealias Exchange = String


public class Channel {

    internal let connection: amqp_connection_state_t
    internal let channel: amqp_channel_t
    internal var _open = false


    public var open: Bool {
        return _open
    }


    init(connection: amqp_connection_state_t, channel: amqp_channel_t) {
        self.connection = connection
        self.channel = channel
        amqp_channel_open(connection, channel)
        self._open = success(connection, printError: true)
    }


    deinit {
        amqp_channel_close(self.connection, self.channel, AMQP_REPLY_SUCCESS)
    }


    public func declareQueue(name: String) -> Queue {
        return Queue(connection: self.connection, channel: self.channel, name: name)
    }


    public func declareExchange(name: Exchange) -> Bool {
        let type = "direct"
        let passive: amqp_boolean_t = 0
        let durable: amqp_boolean_t = 0
        let auto_delete: amqp_boolean_t = 0
        let internl: amqp_boolean_t = 0
        let args = amqp_empty_table
        amqp_exchange_declare(
            connection,
            channel,
            name.amqpBytes,
            type.amqpBytes,
            passive,
            durable,
            auto_delete,
            internl,
            args
        )
        return success(self.connection, printError: true)
    }


    public func publish(message: String, exchange: Exchange, routingKey: String) -> Bool {
        let mandatory: amqp_boolean_t = 0
        let immediate: amqp_boolean_t = 0
        let body = message.amqpBytes
        amqp_basic_publish(
            self.connection,
            self.channel,
            exchange.amqpBytes,
            routingKey.amqpBytes,
            mandatory,
            immediate,
            nil,
            body
        )
        return success(self.connection, printError: true)
    }

}

