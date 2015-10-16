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

    func test_headersExchange() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password)
        let ch = c.openChannel()
        let ex = ch.declareExchange("myheaders", type: .Headers)
        expect(ex.declared) == true
    }

}

