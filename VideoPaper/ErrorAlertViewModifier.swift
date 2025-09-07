//
//  ErrorAlertViewModifier.swift
//  VideoPaper
//
//  Created by Testy McTestface on 9/6/25.
//

import SwiftUI

struct ErrorAlertViewModifier: ViewModifier {
    @Binding var errorAlertItem: Error?
    
    private var isShowingErrorAlert: Binding<Bool> {
        Binding {
            errorAlertItem != nil
        } set: { newValue in
            if !newValue {
                errorAlertItem = nil
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .alert("Uh Oh", isPresented: isShowingErrorAlert, presenting: errorAlertItem) { _ in
                Button("Ok") {}
            } message: { error in
                Text(error.localizedDescription)
            }
    }
}

extension View {
    func alert(for error: Binding<Error?>) -> some View {
        modifier(ErrorAlertViewModifier(errorAlertItem: error))
    }
}
