import SwiftUI
import Charts
import UniformTypeIdentifiers

enum NumberOfEquations: Int {
    case Two = 2, Three = 3
}

struct ContentView: View {
    @State private var solutionMatrixMethod = solutionToText(nil)
    @State private var elapsedMatrix: Double = 0
    
    @State private var solutionGaussian = solutionToText(nil)
    @State private var elapsedGaussian: Double = 0
    
    @State private var selectedNumberOfEquations: NumberOfEquations = .Two
    
    @State private var coeficients: [[Double]] = Array(repeating: Array(repeating: 0, count: 3), count: 2)
    
    @State private var plottingData: [PointData] = []
    
    func refreshSolutions() {
        let startGaussianTime = DispatchTime.now()
        let solGaussian = gaussianElimination(coeficients)
        solutionGaussian = solutionToText(solGaussian)
        let endGaussianTime = DispatchTime.now()
        elapsedGaussian = Double(endGaussianTime.uptimeNanoseconds - startGaussianTime.uptimeNanoseconds) / 1_000_000.0
         
        let startMatrixTime = DispatchTime.now()
        let solMatrix = matrixMethod(coeficients)
        solutionMatrixMethod = solutionToText(solMatrix)
        let endMatrixTime = DispatchTime.now()
        elapsedMatrix = Double(endMatrixTime.uptimeNanoseconds - startMatrixTime.uptimeNanoseconds) / 1_000_000.0
        
        plottingData = []
        if let solGaussian {
            plottingData.append(contentsOf: getPointsForGraphing(coeficients[0], solGaussian, "First"))
            plottingData.append(contentsOf: getPointsForGraphing(coeficients[1], solGaussian, "Second"))
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Input")) {
                Picker("Number of equations", selection: $selectedNumberOfEquations) {
                    Text("2").tag(NumberOfEquations.Two)
                    Text("3").tag(NumberOfEquations.Three)
                }.onChange(of: selectedNumberOfEquations) {
                    if (coeficients.count != selectedNumberOfEquations.rawValue) {
                        plottingData = []
                        coeficients = Array(repeating: Array(repeating: 0, count: selectedNumberOfEquations.rawValue + 1),
                                            count: selectedNumberOfEquations.rawValue)
                    }
                }
                Grid {
                    ForEach(0..<coeficients.count, id: \.self) { row in
                        GridRow {
                            ForEach(0..<coeficients.count, id: \.self) { col in
                                CoeficientInputEditor(coeficient: $coeficients[row][col])
                                    .onChange(of: coeficients[row][col]) {
                                        refreshSolutions()
                                    }
                                Text("x\(col + 1)")
                            }
                            Text(" = ")
                            CoeficientInputEditor(coeficient: $coeficients[row][coeficients.count])
                                .onChange(of: coeficients[row][coeficients.count]) {
                                    refreshSolutions()
                                }
                        }
                    }
                }
                ImportExportButtonsRow(selectedNumberOfEquations: $selectedNumberOfEquations, coeficients: $coeficients)
            }
            if (selectedNumberOfEquations == .Two && !plottingData.isEmpty)
            {
                Section(header: Text("Visualization")) {
                    Chart(plottingData, id: \.x) {
                        LineMark(
                            x: .value("Month", $0.x),
                            y: .value("Hours of Sunshine", $0.y)
                        )
                        .foregroundStyle(by: .value("Equation", $0.equation))
                    }
                    .chartXScale(domain: [plottingData.min(by: {$0.x < $1.x})?.x ?? -50, plottingData.max(by: {$0.x < $1.x})?.x ?? 50])
                }
            }
            Section(header: Text("Solutions")) {
                Text("Gaussian: \(solutionGaussian)")
                Text("Matrix: \(solutionMatrixMethod)")
            }
            Section(header: Text("Time spent")) {
                Text("Gaussian: \(elapsedGaussian)ms")
                Text("Matrix: \(elapsedMatrix)ms")
            }
        }
    }
}

#Preview {
    ContentView()
}
