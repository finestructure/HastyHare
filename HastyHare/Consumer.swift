//
//  Consumer.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 01/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import Foundation
import RabbitMQ
//import FeinstrukturUtils


public typealias Message = String


public class Consumer {

    private let channel: Channel
    internal let tag: String?

    public let started: Bool


    init(channel: Channel, queueName: String) {
        self.channel = channel

        let queue = queueName.amqpBytes
        let noLocal: amqp_boolean_t = 0
        let noAck: amqp_boolean_t = 0
        let isExclusive: amqp_boolean_t = 0
        let args = amqp_empty_table
        let res = amqp_basic_consume(
            self.channel.connection, self.channel.channel, queue, amqp_empty_bytes, noLocal, noAck, isExclusive, args
        )

        self.tag = String(data: res.memory.consumer_tag)
        self.started = success(self.channel.connection, printError: true)
    }

    

    public func pop() -> Message? {
        var frame = amqp_frame_t()

        while true {
            var envelope = amqp_envelope_t()

            amqp_maybe_release_buffers(self.channel.connection)
            let res = amqp_consume_message(self.channel.connection, &envelope, nil, 0)

            if res.reply_type != AMQP_RESPONSE_NORMAL {

                if (res.reply_type == AMQP_RESPONSE_LIBRARY_EXCEPTION
                    && res.library_error == AMQP_STATUS_UNEXPECTED_STATE.rawValue) {

                        let res = amqp_simple_wait_frame(self.channel.connection, &frame)
                        if res != AMQP_STATUS_OK.rawValue {
                            return nil
                        }

                        if Int32(frame.frame_type) == AMQP_FRAME_METHOD {
                            let payloadMethod = payload_method(&frame)
                            if let methodId = MethodId(rawValue: payloadMethod.id) {
                                switch methodId {
                                case .BasicAck:
                                    // if we've turned publisher confirms on, and we've published a message here is a message being confirmed
                                    break
                                case .BasicReturn:
                                    // if a published message couldn't be routed and the mandatory flag was set this is what would be returned. The message then needs to be read.
                                    var msg = amqp_message_t()
                                    let res = amqp_read_message(self.channel.connection, self.channel.channel, &msg, 0)
                                    if res.reply_type != AMQP_RESPONSE_NORMAL {
                                        return nil
                                    }
                                    amqp_destroy_message(&msg)
                                case .ChannelClose:
                                    return nil
                                case .ConnectionClose:
                                    return nil
                                case .ConnectionCloseOk:
                                    return nil
                                default:
                                    print("unexpected method: \(payloadMethod.id)")
                                    return nil
                                }
                            } else {
                                print("unknown method id: \(payloadMethod.id)")
                                return nil
                            }
                        }
                }

            } else {
                let msg = Message(data: envelope.message.body)
                amqp_destroy_envelope(&envelope)
                return msg
            }

        }
    }
    
}

