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

        do { // bind to it
            let c = Connection(host: hostname, port: port)
            c.login(username, password: password)
            let ch = c.openChannel()
            let q = ch.declareQueue("headers_queue")
            q.bindToExchange(exchange, arguments: Arguments(arguments: ["key": "value"]))
        }
    }

}

