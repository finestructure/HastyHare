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


struct PropertiesFlags: OptionSetType {
    let rawValue: UInt32
    static let None             = PropertiesFlags(rawValue: 0)
    static let ContentType      = PropertiesFlags(rawValue: 1 << 15)
    static let ContentEncoding  = PropertiesFlags(rawValue: 1 << 14)
    static let Headers          = PropertiesFlags(rawValue: 1 << 13)
    static let DeliveryMode     = PropertiesFlags(rawValue: 1 << 12)
    static let Priority         = PropertiesFlags(rawValue: 1 << 11)
    static let CorrelationId    = PropertiesFlags(rawValue: 1 << 10)
    static let ReplyTo          = PropertiesFlags(rawValue: 1 <<  9)
    static let Expiration       = PropertiesFlags(rawValue: 1 <<  8)
    static let MessageId        = PropertiesFlags(rawValue: 1 <<  7)
    static let Timestamp        = PropertiesFlags(rawValue: 1 <<  6)
    static let Type             = PropertiesFlags(rawValue: 1 <<  5)
    static let UserId           = PropertiesFlags(rawValue: 1 <<  4)
    static let AppId            = PropertiesFlags(rawValue: 1 <<  3)
    static let ClusterId        = PropertiesFlags(rawValue: 1 <<  2)
}


public class Exchange {

    private let channel: Channel
    public let name: String
    private var _declared = false


    public var declared: Bool {
        return _declared
    }


    init(channel: Channel, name: String, type: ExchangeType = .Direct, passive: Bool, durable: Bool, autoDelete: Bool) {
        self.channel = channel
        self.name = name
        let internl = false
        let args = amqp_empty_table

        amqp_exchange_declare(
            self.channel.connection,
            self.channel.channel,
            name.amqpBytes,
            type.rawValue.amqpBytes,
            passive.amqpBoolean,
            durable.amqpBoolean,
            autoDelete.amqpBoolean,
            internl.amqpBoolean,
            args
        )

        self._declared = self.channel.lastResponse.success
    }


    func publish(bytes: amqp_bytes_t, routingKey: String) -> Bool {
        let mandatory = false
        let immediate = false

        amqp_basic_publish(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            routingKey.amqpBytes,
            mandatory.amqpBoolean,
            immediate.amqpBoolean,
            nil,
            bytes
        )

        return self.channel.lastResponse.success
    }
    
    
    public func publish(message: String, routingKey: String) -> Bool {
        return publish(message.amqpBytes, routingKey: routingKey)
    }


    public func publish(data: NSData, routingKey: String) -> Bool {
        return publish(data.amqpBytes, routingKey: routingKey)
    }


    func publish(message: String, headers: Arguments) -> Bool {
        let mandatory: amqp_boolean_t = 0
        let immediate: amqp_boolean_t = 0
        var properties: amqp_basic_properties_t = {
            var p = amqp_basic_properties_t()
            p._flags = PropertiesFlags.Headers.rawValue
            p.headers = headers.amqpTable
            return p
        }()

        amqp_basic_publish(
            self.channel.connection,
            self.channel.channel,
            self.name.amqpBytes,
            amqp_empty_bytes,
            mandatory,
            immediate,
            &properties,
            message.amqpBytes
        )
        return self.channel.lastResponse.success
    }

}
