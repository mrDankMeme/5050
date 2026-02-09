//
//  CheaterViewModel+InternalNavigation.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation


extension CheaterViewModel {
    func goBackToIdle() {
        cancelCurrentAnalysis() 
        self.state = .idle
    }
}

