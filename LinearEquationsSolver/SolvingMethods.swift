//
//  SolvingMethods.swift
//  LinearEquationsSolver
//
//  Created by Sviatoslav Romankiv on 12.10.2023.
//

import Foundation

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

func multiplyMatrixAndVector(A: [[Double]], B: [Double]) -> [Double]? {
    let rowCountA = A.count
    let columnCountA = A[0].count
    let rowCountB = B.count
    if rowCountA != rowCountB {
        return nil
    }

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


func matrixMethod(_ augmentedMatrix: [[Double]]) -> [Double]? {
    let rowCount = augmentedMatrix.count

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

func gaussianElimination(_ augmentedMatrix: [[Double]]) -> [Double]? {
    var augmentedMatrix = augmentedMatrix

    let rowCount = augmentedMatrix.count
    let columnCount = augmentedMatrix[0].count - 1

    for pivotRow in 0..<rowCount {
        var maxRowIndex = pivotRow
        for i in pivotRow+1..<rowCount {
            if abs(augmentedMatrix[i][pivotRow]) > abs(augmentedMatrix[maxRowIndex][pivotRow]) {
                maxRowIndex = i
            }
        }

        if maxRowIndex != pivotRow {
            augmentedMatrix.swapAt(maxRowIndex, pivotRow)
        }

        let pivotElement = augmentedMatrix[pivotRow][pivotRow]
        if pivotElement == 0 {
            return nil // The matrix is singular (no unique solution)
        }
        for j in pivotRow..<columnCount+1 {
            augmentedMatrix[pivotRow][j] /= pivotElement
        }

        for i in pivotRow+1..<rowCount {
            let factor = augmentedMatrix[i][pivotRow]
            for j in pivotRow..<columnCount+1 {
                augmentedMatrix[i][j] -= factor * augmentedMatrix[pivotRow][j]
            }
        }
    }

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
