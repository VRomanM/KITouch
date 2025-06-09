//
//  String + Extension.swift
//  KITouch
//
//  Created by Роман Вертячих on 09.06.2025.
//

import Foundation

import Foundation

extension String {
    
    func localized() -> String {
        NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
