//
//  ContentView.swift
//  LinearEquationsSolver
//
//  Created by Sviatoslav Romankiv on 07.10.2023.
//

import SwiftUI
import simd


// Function to compute the inverse of a 2x2 matrix
func invert2x2Matrix(_ matrix: [[Double]]) -> [[Double]]? {
    guard matrix.count == 2, matrix[0].count == 2, matrix[1].count == 2 else {
        return nil
    }
    
    let determinant = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
    
    guard determinant != 0.0 else {
        return nil // The matrix is singular; it cannot be inverted
    }
    
    let inverseDeterminant = 1.0 / determinant
    
    return [
        [matrix[1][1] * inverseDeterminant, -matrix[0][1] * inverseDeterminant],
        [-matrix[1][0] * inverseDeterminant, matrix[0][0] * inverseDeterminant]
    ]
}

// Function to compute the inverse of a 3x3 matrix
func invert3x3Matrix(_ matrix: [[Double]]) -> [[Double]]? {
    guard matrix.count == 3, matrix[0].count == 3, matrix[1].count == 3, matrix[2].count == 3 else {
        return nil
    }
    
    let a = matrix[0][0], b = matrix[0][1], c = matrix[0][2]
    let d = matrix[1][0], e = matrix[1][1], f = matrix[1][2]
    let g = matrix[2][0], h = matrix[2][1], i = matrix[2][2]
    
    let determinant = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
    
    guard determinant != 0.0 else {
        return nil // The matrix is singular; it cannot be inverted
    }
    
    let inverseDeterminant = 1.0 / determinant
    
    let invertedMatrix: [[Double]] = [
        [(e * i - f * h) * inverseDeterminant, -(b * i - c * h) * inverseDeterminant, (b * f - c * e) * inverseDeterminant],
        [-(d * i - f * g) * inverseDeterminant, (a * i - c * g) * inverseDeterminant, -(a * f - c * d) * inverseDeterminant],
        [(d * h - e * g) * inverseDeterminant, -(a * h - b * g) * inverseDeterminant, (a * e - b * d) * inverseDeterminant]
    ]
    
    return invertedMatrix
}
// Solve a system of linear equations using matrix methods with an augmented matrix.
func solveLinearSystem(_ augmentedMatrix: [[Double]]) -> [Double]? {
    // Check if the matrix is empty
    if augmentedMatrix.isEmpty {
        return nil
    }

    let rowCount = augmentedMatrix.count
    let columnCount = augmentedMatrix[0].count

    // Extract the coefficient matrix A and constants vector B from the augmented matrix
    let matrixA = Array(augmentedMatrix.map { Array($0[0..<rowCount]) })
    let vectorB = augmentedMatrix.map { $0[rowCount] }

    if (rowCount == 2)
    {
        if let invertedA = invert2x2Matrix(matrixA) {
            if let solution = multiplyMatrixAndVector(A: invertedA, B: vectorB) {
                return solution
            }
        }
    }
    else if (rowCount == 3)
    {
        if let invertedA = invert3x3Matrix(matrixA) {
            if let solution = multiplyMatrixAndVector(A: invertedA, B: vectorB) {
                return solution
            }
        }
    }
    return nil
}

// Solve a system of linear equations using matrix methods.
func multiplyMatrixAndVector(A: [[Double]], B: [Double]) -> [Double]? {
    // Check if the dimensions are valid for matrix multiplication
    let rowCountA = A.count
    let columnCountA = A[0].count
    let rowCountB = B.count
    if rowCountA != rowCountB {
        return nil
    }

    // Perform matrix multiplication
    var result = [Double](repeating: 0.0, count: rowCountA)

    for i in 0..<rowCountA {
        var sum = 0.0
        for j in 0..<columnCountA {
            sum += A[i][j] * B[j]
        }
        result[i] = sum
    }

    return result
}

func gaussianElimination(_ augmentedMatrix: [[Double]]) -> [Double]? {
    var augmentedMatrix = augmentedMatrix

    let rowCount = augmentedMatrix.count
    let columnCount = augmentedMatrix[0].count - 1 // Last column is for the constants

    // Forward elimination (convert to row echelon form)
    for pivotRow in 0..<rowCount {
        // Find the pivot element (the largest absolute value) in the current column
        var maxRowIndex = pivotRow
        for i in pivotRow+1..<rowCount {
            if abs(augmentedMatrix[i][pivotRow]) > abs(augmentedMatrix[maxRowIndex][pivotRow]) {
                maxRowIndex = i
            }
        }

        // Swap rows to make the pivot element the largest in its column
        if maxRowIndex != pivotRow {
            augmentedMatrix.swapAt(maxRowIndex, pivotRow)
        }

        // Normalize the pivot row
        let pivotElement = augmentedMatrix[pivotRow][pivotRow]
        if pivotElement == 0 {
            // The matrix is singular (no unique solution)
            return nil
        }
        for j in pivotRow..<columnCount+1 {
            augmentedMatrix[pivotRow][j] /= pivotElement
        }

        // Eliminate entries below the pivot
        for i in pivotRow+1..<rowCount {
            let factor = augmentedMatrix[i][pivotRow]
            for j in pivotRow..<columnCount+1 {
                augmentedMatrix[i][j] -= factor * augmentedMatrix[pivotRow][j]
            }
        }
    }

    // Back-substitution
    var solution = Array(repeating: 0.0, count: columnCount)
    for i in (0..<rowCount).reversed() {
        solution[i] = augmentedMatrix[i][columnCount]
        for j in i+1..<columnCount {
            solution[i] -= augmentedMatrix[i][j] * solution[j]
        }
    }

    return solution
}

func solutionToText(_ solution: [Double]?) -> String
{
    if let solution {
        var result = ""
        for (i, x) in solution.enumerated() {
            result.append(String(format: "x%d = %.2f ", i, x))
        }
        return result
    }
    return "Input is invalid or there are no solutions"
}

struct ContentView: View {
    enum NumberOfEquations: Int {
        case Two = 2, Three = 3
    }

    @State private var solutionMatrixMethod = "Input is invalid or there are no solutions"
    @State private var elapsedMatrix: Double = 0
    
    @State private var solutionGaussian = "Input is invalid or there are no solutions"
    @State private var elapsedGaussian: Double = 0
    
    @State private var selectedNumberOfEquations: NumberOfEquations = .Two
    
    @State private var coeficients: [[Double]] = Array(repeating: Array(repeating: 0, count: 3), count: 2)
    
    var body: some View {
        List {
            Section(header: Text("Input")) {
                Picker("Number of equations", selection: $selectedNumberOfEquations) {
                    Text("2").tag(NumberOfEquations.Two)
                    Text("3").tag(NumberOfEquations.Three)
                }.onChange(of: selectedNumberOfEquations) {
                    coeficients = Array(repeating: Array(repeating: 0, count: selectedNumberOfEquations.rawValue + 1),
                                        count: selectedNumberOfEquations.rawValue)
                }
                Grid {
                    ForEach(0..<selectedNumberOfEquations.rawValue, id: \.self) { row in
                        GridRow {
                            ForEach(0..<selectedNumberOfEquations.rawValue, id: \.self) { col in
                                TextField("", value: $coeficients[row][col], format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .padding(.all, 3.0)
                                    .overlay(
                                         RoundedRectangle(cornerRadius: 5)
                                             .stroke(Color.black, lineWidth: 1)
                                    )
                                Text("x\(col + 1)")
                            }
                            Text(" = ")
                            TextField("", value: $coeficients[row][selectedNumberOfEquations.rawValue], format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .padding(.all, 3.0)
                                .overlay(
                                     RoundedRectangle(cornerRadius: 5)
                                         .stroke(Color.black, lineWidth: 1)
                                 )
                        }
                    }
                }
                HStack {
                    Button("Load from file") {
                    }.padding(.trailing, 7.0)
                    Button("Visualize") {
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    }.padding(.trailing, 7.0)
                    Button("Compute") {
                        let startGaussianTime = DispatchTime.now()
                        solutionGaussian = solutionToText(gaussianElimination(coeficients))
                        let endGaussianTime = DispatchTime.now()
                        elapsedGaussian = Double(endGaussianTime.uptimeNanoseconds - startGaussianTime.uptimeNanoseconds) / 1_000_000.0 // Convert to milliseconds
                        print(solutionGaussian as Any)
                        
                        let startMatrixTime = DispatchTime.now()
                        solutionMatrixMethod = solutionToText(solveLinearSystem(coeficients))
                        let endMatrixTime = DispatchTime.now()
                        elapsedMatrix = Double(endMatrixTime.uptimeNanoseconds - startMatrixTime.uptimeNanoseconds) / 1_000_000.0 // Convert to milliseconds
                        print(solutionMatrixMethod as Any)
                    }
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
