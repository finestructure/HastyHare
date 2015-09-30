//
//  ConnectionTests.swift
//  HastyHare
//
//  Created by Sven A. Schmidt on 29/09/2015.
//  Copyright © 2015 feinstruktur. All rights reserved.
//

import XCTest
import Nimble
@testable import HastyHare


class ConnectionTests: XCTestCase {

    func test_init() {
        let c = Connection(host: hostname, port: port)
        expect(c.connected) == true
    }


    func test_login() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: password, vhost: "/")
        expect(c.loggedIn) == true
    }


    func test_login_error() {
        let c = Connection(host: hostname, port: port)
        c.login(username, password: "wrong")
        expect(c.loggedIn) == false
    }

}
