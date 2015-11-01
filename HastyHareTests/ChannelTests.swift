//
//  ChannelTests.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import XCTest
import Nimble
import Async
@testable import HastyHare


class ChannelTests: XCTestCase {

    func test_openChannel() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        expect(ch).toNot(beNil())
        expect(ch.channel) == 1
        expect(ch._open) == true
    }


    func test_declareQueue() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let q = ch.declareQueue("queue")
        expect(q.declared) == true
    }


    func test_declareExchange() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let ex = ch.declareExchange("foo")
        expect(ex.declared) == true
    }


    func test_publish() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let ex = ch.declareExchange("ex")
        let res = ex.publish("a message", routingKey: "mytest")
        expect(res) == true
    }


    func test_bindToExchange() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let q = ch.declareQueue("queue1")
        let ex = ch.declareExchange("foo")
        q.bindToExchange("foo", bindingKey: "key1")
        let res = ex.publish("doc message", routingKey: "key1")
        expect(res) == true
    }


    func test_consumer() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let q = ch.declareQueue("queue1")
        let consumer = ch.consumer(q)
        expect(consumer.started) == true
        expect(consumer.tag).toNot(beNil())
    }


    func test_consumer_pop() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let q = ch.declareQueue("queue2")
        let ex = ch.declareExchange("pop")
        q.bindToExchange("pop", bindingKey: "bkey")
        expect(ex.publish("ping", routingKey: "bkey")) == true

        let consumer = ch.consumer(q)
        var msg: Message? = nil
        Async.background {
            msg = consumer.pop()
        }
        expect(msg).toEventuallyNot(beNil(), timeout: 2)
        expect(msg) == Optional("ping")
    }


    func test_publish_data() {
        var msg: Message? = nil
        Async.background {
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q = ch.declareQueue("nsdata")
            let exchange = ch.declareExchange("ex_nsdata")
            q.bindToExchange(exchange, bindingKey: "nsdata")
            let consumer = ch.consumer(q)
            msg = consumer.pop()
            print("done")
        }

        do { // send data
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let exchange = ch.declareExchange("ex_nsdata")
            let data = "data".dataUsingEncoding(NSUTF8StringEncoding)!
            print("sending")
            let res = exchange.publish(data, routingKey: "nsdata")
            expect(res) == true
        }

        expect(msg).toEventuallyNot(beNil(), timeout: 5)
        expect(msg) == Optional("data")
    }


    func test_consumer_listen() {
        let exchange = "ex_listen"
        var messages = [Message]()

        Async.background { // start listening
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q = ch.declareQueue("listen")
            q.bindToExchange(exchange, bindingKey: "listen")
            let consumer = ch.consumer("listen")
            consumer.listen { msg in
                messages.append(msg)
            }
        }

        do { // send data
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let ex = ch.declareExchange(exchange)
            ex.publish("0", routingKey: "listen")
            ex.publish("1", routingKey: "listen")
            ex.publish("2", routingKey: "listen")
        }

        expect(messages.count).toEventually(equal(3), timeout: 2)
        if messages.count == 3 {
            expect(messages[0]) == "0"
            expect(messages[1]) == "1"
            expect(messages[2]) == "2"
        }
    }

}
