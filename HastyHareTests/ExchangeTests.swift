//
//  ExchangeTests.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 30/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import XCTest
import Nimble
@testable import HastyHare


class ExchangeTests: XCTestCase {

    func test_send() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let ex = ch.declareExchange("foo")
        let res = ex.send("a message")
        expect(res) == true
    }

}
