//
//  LocationHistoryStore.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//



import Foundation

public protocol LocationHistoryStore: AnyObject {

    
    var items: [LocationHistoryItem] { get }

    
    func add(_ item: LocationHistoryItem)

    
    func clear()
}
