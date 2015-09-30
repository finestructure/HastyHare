//
//  Channel.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation


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
        let reply = amqp_get_rpc_reply(connection)
        if reply.reply_type.rawValue == AMQP_RESPONSE_NORMAL.rawValue {
            self._open = true
        } else {
            print(errorDescriptionForReply(reply))
        }
    }


    deinit {
        amqp_channel_close(self.connection, self.channel, AMQP_REPLY_SUCCESS)
    }


    public func declareQueue(name: String) -> Queue {
        return Queue(connection: self.connection, channel: self.channel, name: name)
    }

}

