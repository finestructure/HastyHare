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


    init(channel: Channel, name: String, type: ExchangeType = .Direct) {
        self.channel = channel
        self.name = name

        let passive: amqp_boolean_t = 0
        let durable: amqp_boolean_t = 0
        let auto_delete: amqp_boolean_t = 0
        let internl: amqp_boolean_t = 0
        let args = amqp_empty_table
        amqp_exchange_declare(
            self.channel.connection,
            self.channel.channel,
            name.amqpBytes,
            type.rawValue.amqpBytes,
            passive,
            durable,
            auto_delete,
            internl,
            args
        )
        self._declared = success(self.channel.connection, printError: true)
    }

}
