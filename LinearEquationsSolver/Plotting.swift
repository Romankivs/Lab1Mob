//
//  Plotting.swift
//  LinearEquationsSolver
//
//  Created by Sviatoslav Romankiv on 12.10.2023.
//

import Foundation

struct PointData {
    var x: Double
    var y: Double
    var equation: String
}

func getPointsForGraphing(_ coeficients: [Double], _ solution: [Double], _ equation: String) -> [PointData] {
    let xLeft = solution[0] - 10
    let xRight = solution[0] + 10
    
    let yLeft = (coeficients[2] - coeficients[0] * xLeft) / coeficients[1]
    let yRight = (coeficients[2] - coeficients[0] * xRight) / coeficients[1]

    return [PointData(x: xLeft, y: yLeft, equation: equation), PointData(x: xRight, y: yRight, equation: equation)]
}
