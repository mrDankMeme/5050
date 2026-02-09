//
//  FeatureItem.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import Foundation

struct FeatureItem: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}
