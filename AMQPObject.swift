//
//  AMQPObject.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 12/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ


public class AMQPObject {
    private let _connection: amqp_connection_state_t
    private let _channel: amqp_channel_t

    init(connection: amqp_connection_state_t, channel: amqp_channel_t) {
        self._connection = connection
        self._channel = channel
    }

    public var connection: amqp_connection_state_t {
        return self._connection
    }

    public var channel: amqp_channel_t {
        return self._channel
    }

}
