import Foundation
import CoreGraphics

// MARK: - CGVector Extensions
extension CGVector {
    var magnitude: CGFloat {
        return sqrt(dx * dx + dy * dy)
    }

    func normalized() -> CGVector {
        let mag = magnitude
        if mag == 0 { return CGVector(dx: 0, dy: 0) }
        return CGVector(dx: dx / mag, dy: dy / mag)
    }

    func rotated(by angle: CGFloat) -> CGVector {
        let cos = Darwin.cos(angle)
        let sin = Darwin.sin(angle)
        return CGVector(
            dx: dx * cos - dy * sin,
            dy: dx * sin + dy * cos
        )
    }

    static func +(lhs: CGVector, rhs: CGVector) -> CGVector {
        return CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }

    static func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }
}

// MARK: - Line Intersection Functions
func lineSegmentsIntersect(a: CGPoint, b: CGPoint, c: CGPoint, d: CGPoint) -> Bool {
    func ccw(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> Bool {
        return (p3.y - p1.y) * (p2.x - p1.x) > (p2.y - p1.y) * (p3.x - p1.x)
    }

    return ccw(a, c, d) != ccw(b, c, d) && ccw(a, b, c) != ccw(a, b, d)
}

// MARK: - Distance Calculations
func distanceFromPoint(_ point: CGPoint, toSegment a: CGPoint, _ b: CGPoint) -> CGFloat {
    let v = CGVector(dx: b.x - a.x, dy: b.y - a.y)
    let w = CGVector(dx: point.x - a.x, dy: point.y - a.y)

    let c1 = v.dx * w.dx + v.dy * w.dy
    if c1 <= 0 {
        return sqrt(pow(point.x - a.x, 2) + pow(point.y - a.y, 2))
    }

    let c2 = v.dx * v.dx + v.dy * v.dy
    if c2 <= c1 {
        return sqrt(pow(point.x - b.x, 2) + pow(point.y - b.y, 2))
    }

    let t = c1 / c2
    let projectedPoint = CGPoint(x: a.x + t * v.dx, y: a.y + t * v.dy)
    return sqrt(pow(point.x - projectedPoint.x, 2) + pow(point.y - projectedPoint.y, 2))
}

func minimumDistance(from a1: CGPoint, to b1: CGPoint, and a2: CGPoint, to b2: CGPoint) -> CGFloat {
    // Check if segments intersect
    if lineSegmentsIntersect(a: a1, b: b1, c: a2, d: b2) {
        return 0
    }

    // Check distances from endpoints to opposite segments
    let distances = [
        distanceFromPoint(a1, toSegment: a2, b2),
        distanceFromPoint(b1, toSegment: a2, b2),
        distanceFromPoint(a2, toSegment: a1, b1),
        distanceFromPoint(b2, toSegment: a1, b1)
    ]

    return distances.min() ?? CGFloat.greatestFiniteMagnitude
}
