import SwiftUI

struct CoeficientInputEditor: View {
    @Binding var coeficient: Double
    
    var body: some View {
        TextField("", value: $coeficient, format: .number)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .padding(.all, 3.0)
            .overlay(
                 RoundedRectangle(cornerRadius: 5)
                     .stroke(Color.black, lineWidth: 1)
            )
    }
}
