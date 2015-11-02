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
        do {
            let args = Arguments(arguments: [String:String]())
            expect(args.amqpTable.num_entries) == 0
        }
        do {
            let args = Arguments(arguments: ["key": "value2", "x-match": "all"])
            expect(args.amqpTable.num_entries) == 2
            expect(String(amqpBytes: args.amqpTable.entries[0].key)) == Optional("key")
            let val = args.amqpTable.entries[0].value
            expect(val.kind) == UInt8("x".unicodeScalars.first?.value ?? 0)
            expect(String(amqpBytes: args.amqpTable.entries[1].key)) == Optional("x-match")
        }
    }


    func test_bindToExchange() {
        let exchange = "myheaders"
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        ch.declareExchange("myheaders", type: .Headers)
        let q = ch.declareQueue("q")
        expect(q.bindToExchange(exchange,
            arguments: Arguments(arguments: ["foo": "bar"]))) == true
    }




    func test_headersExchange_single() {
        let exchange = "myheaders"
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let ex = ch.declareExchange("myheaders", type: .Headers)
        let q1 = ch.declareQueue("q1")

        do { // send message
            expect(q1.bindToExchange(exchange,
                arguments: Arguments(arguments: ["a": "1"]))) == true
            ex.publish("msg 1", headers: Arguments(arguments: ["a": "1"]))
        }

        var msg: String?

        Async.background {
            let consumer = ch.consumer(q1)
            consumer.listen { d in
                if let s = String(data: d, encoding: NSUTF8StringEncoding) {
                    msg = s
                }
            }
        }

        expect(msg).toEventuallyNot(beNil(), timeout: 2)
        expect(msg) == Optional("msg 1")
    }


    func test_headersExchange_two_queues() {
        let exchange = "myheaders2"
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let ex = ch.declareExchange("myheaders2", type: .Headers)

        do { // send message
            let q1 = ch.declareQueue("q1")
            let q2 = ch.declareQueue("q2")
            expect(q1.bindToExchange(exchange,
                arguments: Arguments(arguments: ["a": "1"]))) == true
            expect(q2.bindToExchange(exchange,
                arguments: Arguments(arguments: ["a": "2"]))) == true
            ex.publish("msg 1", headers: Arguments(arguments: ["a": "1"]))
        }

        var msg: String?

        Async.background { // q1
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q1 = ch.declareQueue("q1")
            let consumer = ch.consumer(q1)
            consumer.listen { d in
                if let s = String(data: d, encoding: NSUTF8StringEncoding) {
                    msg = s
                }
            }
        }

        Async.background { // q2
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q2 = ch.declareQueue("q2")
            let consumer = ch.consumer(q2)
            consumer.listen { msg in
                fail("should not have received \(msg) in q2")
            }
        }

        expect(msg).toEventually(equal(Optional("msg 1")), timeout: 10)
    }

}

