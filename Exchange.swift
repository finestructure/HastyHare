//
//  Exchange.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 12/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


public enum ExchangeType: String {
    case Direct = "direct"
    case Fanout = "fanout"
    case Topic = "topic"
    case Headers = "headers"
}


public class Exchange {

    private let channel: Channel
    internal let name: String
    private var _declared = false


    public var declared: Bool {
        return _declared
    }


    init(channel: Channel, name: String, type: ExchangeType = .Direct, passive: Bool = false, durable: Bool = false, autoDelete: Bool = false) {
        self.channel = channel
        self.name = name

        let internl: amqp_boolean_t = 0
        let args = amqp_empty_table
        amqp_exchange_declare(
            self.channel.connection,
            self.channel.channel,
            name.amqpBytes,
            type.rawValue.amqpBytes,
            amqp_boolean_t(UInt(passive)),
            amqp_boolean_t(UInt(durable)),
            amqp_boolean_t(UInt(autoDelete)),
            internl,
            args
        )
        self._declared = success(self.channel.connection, printError: true)
    }


    func publish(bytes: amqp_bytes_t, routingKey: String) -> Bool {
        let mandatory: amqp_boolean_t = 0
        let immediate: amqp_boolean_t = 0
        amqp_basic_publish(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            routingKey.amqpBytes,
            mandatory,
            immediate,
            nil,
            bytes
        )
        return success(self.channel.connection, printError: true)
    }


    public func publish(message: String, routingKey: String) -> Bool {
        return publish(message.amqpBytes, routingKey: routingKey)
    }


    public func publish(data: NSData, routingKey: String) -> Bool {
        return publish(data.amqpBytes, routingKey: routingKey)
    }

}
