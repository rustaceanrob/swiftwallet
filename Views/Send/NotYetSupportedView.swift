//
//  NotYetSupportedView.swift
//  Magma
//
//  Created by Robert Netzke on 1/26/24.
//

import SwiftUI

struct NotYetSupportedView: View {
    var body: some View {
        FadesView {
            Text("Payment type not supported yet.")
        }
    }
}

struct NotYetSupportedView_Previews: PreviewProvider {
    static var previews: some View {
        NotYetSupportedView()
    }
}
