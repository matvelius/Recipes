//
//  View+Extensions.swift
//  RecipeApp
//
//  Created by Matvey Kostukovsky on 11/3/24.
//

import SwiftUI

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
