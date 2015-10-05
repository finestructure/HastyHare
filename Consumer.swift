//
//  Consumer.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 01/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


public class Consumer {

    private let connection: amqp_connection_state_t
    private let channel: amqp_channel_t
    internal let tag: String?

    public let started: Bool


    init(connection: amqp_connection_state_t, channel: amqp_channel_t, queueName: String) {
        self.connection = connection
        self.channel = channel

        let queue = queueName.amqpBytes
        let noLocal: amqp_boolean_t = 0
        let noAck: amqp_boolean_t = 0
        let isExclusive: amqp_boolean_t = 0
        let args = amqp_empty_table
        let res = amqp_basic_consume(
            connection, channel, queue, amqp_empty_bytes, noLocal, noAck, isExclusive, args
        )

        self.tag = String(data: res.memory.consumer_tag)
        self.started = success(connection, printError: true)
   }

}

