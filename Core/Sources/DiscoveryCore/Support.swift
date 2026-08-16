import Foundation

@inlinable
public func clamp(_ value: Double, _ range: ClosedRange<Double>) -> Double {
    min(max(value, range.lowerBound), range.upperBound)
}

public func mean(_ values: [Double]) -> Double {
    guard !values.isEmpty else { return 0 }
    return values.reduce(0, +) / Double(values.count)
}
