//
//  ExchangeTests.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 16/10/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import XCTest
import Nimble
import Async
@testable import HastyHare


class ExchangeTests: XCTestCase {

    func test_Arguments() {
        let args = Arguments(arguments: [String:String]())
        expect(args.amqpTable.num_entries) == 0
    }


    func test_headersExchange() {
        let exchange = "myheaders"

        do { // declare exchange
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let ex = ch.declareExchange(exchange, type: .Headers)
            expect(ex.declared) == true
        }

        var messages = [String: [Message]]()

        Async.background { // bind q1 to it
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q = ch.declareQueue("q1")
            q.bindToExchange(exchange, arguments: Arguments(arguments: ["key": "value1"]))
            messages[q.name] = []

            let consumer = ch.consumer(q)
            consumer.listen { msg in
                messages[q.name]?.append(msg)
            }
        }

        Async.background { // bind q2 to it
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q = ch.declareQueue("q2")
            q.bindToExchange(exchange, arguments: Arguments(arguments: ["key": "value2"]))
            messages[q.name] = []

            let consumer = ch.consumer(q)
            consumer.listen { msg in
                messages[q.name]?.append(msg)
            }
        }

        do { // send message
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let ex = ch.declareExchange(exchange)
            ex.publish("msg 1", headers: Arguments(arguments: ["key": "value1"]))
        }

        expect(messages["q1"]?.count).toEventually(equal(1), timeout: 3)
        expect(messages["q1"]?.first) == Optional("msg 1")
        expect(messages["q2"]?.count) == 0
    }

}

