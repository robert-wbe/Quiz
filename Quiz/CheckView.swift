//
//  CheckView.swift
//  Quiz
//
//  Created by Robert Wiebe on 30.05.21.
//

import SwiftUI

struct CheckView: View {
    var body: some View {
        LottieView(filename: "check")
            .frame(width: 200, height: 200)
    }
}

struct CheckView_Previews: PreviewProvider {
    static var previews: some View {
        CheckView()
    }
}
