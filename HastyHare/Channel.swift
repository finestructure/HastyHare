//
//  Channel.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


public class Channel {

    private let _connection: amqp_connection_state_t
    private let _channel: amqp_channel_t
    internal var _open = false


    init(connection: amqp_connection_state_t, channel: amqp_channel_t) {
        self._connection = connection
        self._channel = channel
        amqp_channel_open(connection, channel)
        self._open = success(connection, printError: true)
    }


    deinit {
        // FIXME: this triggers an EXC_BAD_ACCESS on deinit
        //        amqp_channel_close(self.connection, self.channel, AMQP_REPLY_SUCCESS)
    }


    public var open: Bool {
        return _open
    }

    public var connection: amqp_connection_state_t {
        return self._connection
    }

    public var channel: amqp_channel_t {
        return self._channel
    }


    public func declareQueue(name: String) -> Queue {
        return Queue(connection: self.connection, channel: self.channel, name: name)
    }


    public func declareExchange(name: String, type: ExchangeType = .Direct) -> Exchange {
        return Exchange(channel: self, name: name, type: type)
    }


    public func publish(bytes: amqp_bytes_t, exchange: String, routingKey: String) -> Bool {
        let mandatory: amqp_boolean_t = 0
        let immediate: amqp_boolean_t = 0
        amqp_basic_publish(
            self.connection,
            self.channel,
            exchange.amqpBytes,
            routingKey.amqpBytes,
            mandatory,
            immediate,
            nil,
            bytes
        )
        return success(self.connection, printError: true)
    }

    
    public func publish(message: String, exchange: String, routingKey: String) -> Bool {
        return publish(message.amqpBytes, exchange: exchange, routingKey: routingKey)
    }


    public func publish(data: NSData, exchange: String, routingKey: String) -> Bool {
        return publish(data.amqpBytes, exchange: exchange, routingKey: routingKey)
    }


    public func consumer(queueName: String) -> Consumer {
        return Consumer(connection: self.connection, channel: self.channel, queueName: queueName)
    }


    public func consumer(queue: Queue) -> Consumer {
        return Consumer(connection: self.connection, channel: self.channel, queueName: queue.name)
    }

}

