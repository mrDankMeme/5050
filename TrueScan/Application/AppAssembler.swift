//
//  AppAssembler.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Swinject

enum AppAssembler {
    static func make() -> Assembler {
        Assembler([
            ServicesAssembly()
        ])
    }
}
