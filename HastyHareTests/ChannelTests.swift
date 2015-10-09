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
        expect(ch.declareExchange("foo")) == true
    }


    func test_publish() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let res = ch.publish("a message", exchange: "", routingKey: "mytest")
        expect(res) == true
    }


    func test_bindToExchange() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let q = ch.declareQueue("queue1")
        ch.declareExchange("foo")
        q.bindToExchange("foo", bindingKey: "key1")
        let res = ch.publish("doc message", exchange: "foo", routingKey: "key1")
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
        ch.declareExchange("pop")
        q.bindToExchange("pop", bindingKey: "bkey")
        expect(ch.publish("ping", exchange: "pop", routingKey: "bkey")) == true

        let consumer = ch.consumer(q)
        var msg: Message? = nil
        Async.background {
            msg = consumer.pop()
        }
        expect(msg).toEventuallyNot(beNil(), timeout: 2)
        expect(msg) == Optional("ping")
    }


    func test_publish_data() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        ch.declareExchange("nsdata")

        // send data
        let data = "data".dataUsingEncoding(NSUTF8StringEncoding)!
        let res = ch.publish(data, exchange: "", routingKey: "mytest")
        expect(res) == true

        // check result
        let q = ch.declareQueue("mytest")
        q.bindToExchange("nsdata", bindingKey: "mytest")
        let consumer = ch.consumer("mytest")
        var msg: Message? = nil
        Async.background {
            msg = consumer.pop()
        }
        expect(msg).toEventuallyNot(beNil(), timeout: 2)
        expect(msg) == Optional("data")
    }

}
