import SwiftUI

struct SparklineView: View {
    let data: [Double]
    var color: Color = .secondary
    var height: CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            if data.count >= 2, let minVal = data.min(), let maxVal = data.max() {
                let range = max(maxVal - minVal, 0.001)
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = geo.size.width * CGFloat(index) / CGFloat(data.count - 1)
                        let y = geo.size.height * (1 - CGFloat((value - minVal) / range))
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, lineWidth: 1.5)
            }
        }
        .frame(height: height)
    }
}
