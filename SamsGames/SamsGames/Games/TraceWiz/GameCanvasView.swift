import SwiftUI

struct GameCanvasView: UIViewRepresentable {
    @ObservedObject var gameState: TraceWizGameState
    let canvasSize: CGSize

    func makeUIView(context: Context) -> UIScrollView {
        print("✅ TraceWiz: makeUIView() called - canvasSize: \(canvasSize)")

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.bouncesZoom = false

        let drawingView = DrawingView()
        drawingView.gameState = gameState
        drawingView.backgroundColor = .white
        drawingView.isUserInteractionEnabled = true

        // Set the drawing view size to be 12x taller for scrolling (matches path generation)
        let fullHeight = max(canvasSize.height * 12, 8000)
        drawingView.frame = CGRect(x: 0, y: 0, width: canvasSize.width, height: fullHeight)
        scrollView.contentSize = CGSize(width: canvasSize.width, height: fullHeight)

        print("✅ TraceWiz: drawingView frame set to: \(drawingView.frame)")

        // Minimal bottom inset
        let bottomInset: CGFloat = 20
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset

        scrollView.addSubview(drawingView)

        // Store drawing view reference
        scrollView.tag = 999
        drawingView.tag = 1000

        // Configure scrolling behavior for drawing - LOCK IT DOWN
        scrollView.isScrollEnabled = false  // Disable manual scrolling - we'll auto-scroll
        scrollView.canCancelContentTouches = false
        scrollView.delaysContentTouches = false
        scrollView.maximumZoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.isDirectionalLockEnabled = true  // Lock scrolling direction
        scrollView.alwaysBounceVertical = false     // Prevent vertical bounce
        scrollView.alwaysBounceHorizontal = false   // Prevent horizontal bounce
        scrollView.isPagingEnabled = false          // Disable paging

        // Prevent automatic content inset adjustments
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        guard let drawingView = uiView.viewWithTag(1000) as? DrawingView else { return }

        drawingView.gameState = gameState

        // Always update frame to match current canvas size
        let fullHeight = max(canvasSize.height * 12, 8000)
        let targetWidth = max(canvasSize.width, uiView.frame.width)
        let newFrame = CGRect(x: 0, y: 0, width: targetWidth, height: fullHeight)

        if drawingView.frame.size != newFrame.size {
            print("✅ TraceWiz: updateUIView() - updating frame from \(drawingView.frame) to \(newFrame)")
            drawingView.frame = newFrame
            uiView.contentSize = CGSize(width: targetWidth, height: fullHeight)
        }

        // Smart auto-scroll
        if gameState.phase == .running {
            let currentOffset = uiView.contentOffset.y
            let visibleHeight = uiView.frame.height
            let visibleBottom = currentOffset + visibleHeight
            let scrollTriggerPoint = visibleBottom - 100

            var shouldScroll = false
            var maxY: CGFloat = 0

            // Check black line
            if gameState.revealedSegmentCount > 0 && gameState.revealedSegmentCount <= gameState.segments.count {
                let revealedEndSegment = gameState.segments[min(gameState.revealedSegmentCount - 1, gameState.segments.count - 1)]
                let blackLineY = revealedEndSegment.end.y
                maxY = max(maxY, blackLineY)
                if blackLineY >= scrollTriggerPoint {
                    shouldScroll = true
                }
            }

            // Check blue line
            if let lastPlayerPoint = gameState.player.points.last {
                let blueLineY = lastPlayerPoint.y
                maxY = max(maxY, blueLineY)
                if blueLineY >= scrollTriggerPoint {
                    shouldScroll = true
                }
            }

            if shouldScroll {
                let targetOffset = maxY - visibleHeight * 0.7
                let maxScroll = uiView.contentSize.height - visibleHeight
                let clampedOffset = max(0, min(targetOffset, maxScroll))

                if abs(currentOffset - clampedOffset) > 30 {
                    if gameState.player.isDrawing {
                        drawingView.pauseDrawingForScroll()
                    }

                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                        uiView.contentOffset = CGPoint(x: 0, y: clampedOffset)
                    }, completion: { _ in
                        if gameState.player.isDrawing {
                            drawingView.resumeDrawingAfterScroll()
                        }
                    })
                }
            }
        }

        // Handle phase changes for redraw timer
        switch gameState.phase {
        case .running, .countdown:
            drawingView.startRedrawTimer()
        case .paused:
            drawingView.startRedrawTimer()
        case .idle:
            uiView.contentOffset = .zero
            drawingView.setNeedsDisplay()
        case .ended:
            drawingView.stopRedrawTimer()
        }

        drawingView.setNeedsDisplay()
    }

    class DrawingView: UIView {
        var gameState: TraceWizGameState? {
            didSet {
                if gameState?.phase == .running {
                    startRedrawTimer()
                }
            }
        }
        private var currentPath = UIBezierPath()
        private var redrawTimer: Timer?
        private var isDrawingPaused = false
        private var resumeDrawingTimer: Timer?

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupGestures()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupGestures()
        }

        deinit {
            redrawTimer?.invalidate()
        }

        func startRedrawTimer() {
            redrawTimer?.invalidate()
            redrawTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
                self.setNeedsDisplay()
            }
        }

        func stopRedrawTimer() {
            redrawTimer?.invalidate()
            redrawTimer = nil
        }

        func pauseDrawingForScroll() {
            isDrawingPaused = true
            resumeDrawingTimer?.invalidate()
        }

        func resumeDrawingAfterScroll() {
            resumeDrawingTimer?.invalidate()
            resumeDrawingTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: false) { _ in
                self.isDrawingPaused = false
            }
        }

        private func isPointBeyondBlackLineTip(_ point: CGPoint, gameState: TraceWizGameState) -> Bool {
            guard gameState.revealedSegmentCount > 0,
                  gameState.revealedSegmentCount <= gameState.segments.count else {
                return false
            }

            let revealedEndSegment = gameState.segments[min(gameState.revealedSegmentCount - 1, gameState.segments.count - 1)]
            let blackLineTipY = revealedEndSegment.end.y

            return point.y > blackLineTipY + 5
        }

        private func setupGestures() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture.maximumNumberOfTouches = 1
            panGesture.minimumNumberOfTouches = 1
            panGesture.cancelsTouchesInView = false
            panGesture.delaysTouchesBegan = false
            panGesture.delaysTouchesEnded = false
            addGestureRecognizer(panGesture)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture.cancelsTouchesInView = false
            tapGesture.delaysTouchesBegan = false
            tapGesture.delaysTouchesEnded = false
            addGestureRecognizer(tapGesture)

            panGesture.delegate = self
            tapGesture.delegate = self
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let gameState = gameState else { return }

            if gameState.phase == .ended {
                return
            }

            let point = gesture.location(in: self)

            switch gesture.state {
            case .began:
                if gameState.phase == .running || gameState.phase == .countdown || gameState.phase == .paused {
                    if gameState.phase == .paused {
                        gameState.resumeGame()
                    }

                    gameState.player.isDrawing = true
                    gameState.player.points = [point]
                    currentPath.removeAllPoints()
                    currentPath.move(to: point)

                    DispatchQueue.main.async {
                        self.setNeedsDisplay()
                    }
                }

            case .changed:
                if gameState.player.isDrawing && !isDrawingPaused {
                    if let lastPoint = gameState.player.points.last {
                        let distance = sqrt(pow(point.x - lastPoint.x, 2) + pow(point.y - lastPoint.y, 2))
                        if distance > 2 && !isPointBeyondBlackLineTip(point, gameState: gameState) {
                            gameState.player.points.append(point)
                            currentPath.addLine(to: point)

                            gameState.checkGameRules()

                            if gameState.player.points.count % 5 == 0 {
                                DispatchQueue.main.async {
                                    self.setNeedsDisplay()
                                }
                            }
                        }
                    } else {
                        gameState.player.points.append(point)
                        currentPath.addLine(to: point)
                        gameState.checkGameRules()
                    }
                }

            case .ended, .cancelled:
                if gameState.player.isDrawing {
                    gameState.player.isDrawing = false
                }

            default:
                break
            }

            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }

        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let gameState = gameState else { return }

            if gameState.phase == .paused {
                gameState.resumeGame()
            }
        }

        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext(),
                  let gameState = gameState else {
                print("❌ TraceWiz: draw() called but context or gameState is nil")
                return
            }

            print("✅ TraceWiz: draw() called - rect: \(rect), segments: \(gameState.segments.count), phase: \(gameState.phase)")

            // Draw grid
            drawGrid(in: context, rect: rect)

            // Draw black reference path
            drawReferencePath(in: context, gameState: gameState)

            // Draw player path
            drawPlayerPath(in: context, gameState: gameState)

            // Draw end line
            drawEndLine(in: context, gameState: gameState)

            // Draw flashing blue starting point indicator
            drawStartingPointIndicator(in: context, gameState: gameState)

            // Draw pause indicator
            if gameState.phase == .paused {
                drawPauseIndicator(in: context, rect: rect)
            }
        }

        private func drawGrid(in context: CGContext, rect: CGRect) {
            context.saveGState()

            context.setStrokeColor(UIColor.black.withAlphaComponent(0.08).cgColor)
            context.setLineWidth(0.5)

            let gridSize: CGFloat = 40

            var x: CGFloat = 0
            while x <= rect.width {
                context.move(to: CGPoint(x: x, y: 0))
                context.addLine(to: CGPoint(x: x, y: rect.height))
                x += gridSize
            }

            var y: CGFloat = 0
            while y <= rect.height {
                context.move(to: CGPoint(x: 0, y: y))
                context.addLine(to: CGPoint(x: rect.width, y: y))
                y += gridSize
            }

            context.strokePath()
            context.restoreGState()
        }

        private func drawReferencePath(in context: CGContext, gameState: TraceWizGameState) {
            guard gameState.segments.count > 0 else { return }

            let segmentsToDraw = max(1, gameState.revealedSegmentCount)

            // Draw tolerance field
            if gameState.phase == .running || gameState.phase == .countdown {
                drawToleranceField(in: context, gameState: gameState, segmentsToDraw: segmentsToDraw)
            }

            // Draw black reference line
            context.saveGState()
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(GameConstants.lineWidth)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            var endPoint: CGPoint?
            var previousPoint: CGPoint?

            if segmentsToDraw > 0 {
                let firstSegment = gameState.segments[0]
                context.move(to: firstSegment.start)
                context.addLine(to: firstSegment.end)
                previousPoint = firstSegment.start
                endPoint = firstSegment.end

                for i in 1..<min(segmentsToDraw, gameState.segments.count) {
                    let segment = gameState.segments[i]
                    context.addLine(to: segment.end)
                    previousPoint = endPoint
                    endPoint = segment.end
                }
            }

            context.strokePath()

            // Draw arrow tip
            if let endPoint = endPoint, let previousPoint = previousPoint, segmentsToDraw > 0 {
                drawArrowTip(in: context, from: previousPoint, to: endPoint)
            }

            context.restoreGState()
        }

        private func drawToleranceField(in context: CGContext, gameState: TraceWizGameState, segmentsToDraw: Int) {
            guard segmentsToDraw > 0 else { return }

            context.saveGState()

            context.setStrokeColor(UIColor.green.withAlphaComponent(0.2).cgColor)

            let toleranceDistance = gameState.difficulty.maxDistanceFromLine
            let toleranceFieldWidth = toleranceDistance * 2

            context.setLineWidth(toleranceFieldWidth)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            let firstSegment = gameState.segments[0]
            context.move(to: firstSegment.start)
            context.addLine(to: firstSegment.end)

            for i in 1..<min(segmentsToDraw, gameState.segments.count) {
                let segment = gameState.segments[i]
                context.addLine(to: segment.end)
            }

            context.strokePath()
            context.restoreGState()
        }

        private func drawArrowTip(in context: CGContext, from previousPoint: CGPoint, to endPoint: CGPoint) {
            let dx = endPoint.x - previousPoint.x
            let dy = endPoint.y - previousPoint.y
            let length = sqrt(dx * dx + dy * dy)

            guard length > 0 else { return }

            let unitX = dx / length
            let unitY = dy / length

            let arrowLength: CGFloat = 20
            let arrowWidth: CGFloat = 16

            let arrowBack = CGPoint(
                x: endPoint.x - unitX * arrowLength,
                y: endPoint.y - unitY * arrowLength
            )

            let perpX = -unitY
            let perpY = unitX

            let leftWing = CGPoint(
                x: arrowBack.x + perpX * arrowWidth / 2,
                y: arrowBack.y + perpY * arrowWidth / 2
            )

            let rightWing = CGPoint(
                x: arrowBack.x - perpX * arrowWidth / 2,
                y: arrowBack.y - perpY * arrowWidth / 2
            )

            context.saveGState()

            // White outline
            context.setFillColor(UIColor.white.cgColor)
            context.move(to: endPoint)
            context.addLine(to: leftWing)
            context.addLine(to: rightWing)
            context.closePath()
            context.fillPath()

            // Black arrow
            let insetAmount: CGFloat = 2
            let innerLeftWing = CGPoint(
                x: leftWing.x + (endPoint.x - leftWing.x) * insetAmount / arrowWidth,
                y: leftWing.y + (endPoint.y - leftWing.y) * insetAmount / arrowLength
            )
            let innerRightWing = CGPoint(
                x: rightWing.x + (endPoint.x - rightWing.x) * insetAmount / arrowWidth,
                y: rightWing.y + (endPoint.y - rightWing.y) * insetAmount / arrowLength
            )

            context.setFillColor(UIColor.black.cgColor)
            context.move(to: endPoint)
            context.addLine(to: innerLeftWing)
            context.addLine(to: innerRightWing)
            context.closePath()
            context.fillPath()

            context.restoreGState()
        }

        private func drawPlayerPath(in context: CGContext, gameState: TraceWizGameState) {
            if gameState.player.points.count == 0 {
                return
            }

            if gameState.player.points.count == 1 {
                context.saveGState()
                let color = gameState.player.isEliminated ?
                    UIColor.gray.withAlphaComponent(0.5) :
                    UIColor(gameState.player.color)
                context.setFillColor(color.cgColor)
                let point = gameState.player.points[0]
                let radius: CGFloat = 18
                let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
                context.fillEllipse(in: rect)
                context.restoreGState()
                return
            }

            context.saveGState()

            let color = gameState.player.isEliminated ?
                UIColor.gray.withAlphaComponent(0.5) :
                UIColor(gameState.player.color)

            context.setStrokeColor(color.cgColor)
            context.setLineWidth(4)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            context.move(to: gameState.player.points[0])
            for i in 1..<gameState.player.points.count {
                context.addLine(to: gameState.player.points[i])
            }

            context.strokePath()

            // Draw ball tip
            if let lastPoint = gameState.player.points.last {
                context.setFillColor(color.cgColor)
                let ballRadius: CGFloat = 18
                let ballRect = CGRect(x: lastPoint.x - ballRadius,
                                      y: lastPoint.y - ballRadius,
                                      width: ballRadius * 2,
                                      height: ballRadius * 2)
                context.fillEllipse(in: ballRect)

                // Highlight
                context.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
                let highlightRadius: CGFloat = ballRadius * 0.4
                let highlightRect = CGRect(x: lastPoint.x - highlightRadius + 1,
                                           y: lastPoint.y - highlightRadius - 1,
                                           width: highlightRadius * 2,
                                           height: highlightRadius * 2)
                context.fillEllipse(in: highlightRect)
            }

            context.restoreGState()
        }

        private func drawEndLine(in context: CGContext, gameState: TraceWizGameState) {
            guard gameState.endLine != .zero else { return }

            context.saveGState()

            context.setStrokeColor(UIColor.green.cgColor)
            context.setLineWidth(8)
            context.setLineCap(.round)

            let lineWidth: CGFloat = 100
            let startPoint = CGPoint(x: gameState.endLine.x - lineWidth/2, y: gameState.endLine.y)
            let endPoint = CGPoint(x: gameState.endLine.x + lineWidth/2, y: gameState.endLine.y)

            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.strokePath()

            // "FINISH" text
            let text = "FINISH"
            let font = UIFont.systemFont(ofSize: 20, weight: .bold)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.green
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: gameState.endLine.x - textSize.width/2,
                y: gameState.endLine.y - 35,
                width: textSize.width,
                height: textSize.height
            )
            attributedString.draw(in: textRect)

            context.restoreGState()
        }

        private func drawStartingPointIndicator(in context: CGContext, gameState: TraceWizGameState) {
            guard gameState.player.points.count == 0 &&
                  (gameState.phase == .idle || gameState.phase == .countdown ||
                   (gameState.phase == .running && gameState.roundTime < 2.0)) else { return }

            guard gameState.startingPoint != .zero else { return }

            context.saveGState()

            let time = Date().timeIntervalSince1970
            let flashSpeed = 2.0
            let alpha = (sin(time * flashSpeed * .pi) + 1.0) / 2.0

            context.setFillColor(UIColor.blue.withAlphaComponent(alpha).cgColor)
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(2)

            let radius: CGFloat = 24
            let circleRect = CGRect(
                x: gameState.startingPoint.x - radius,
                y: gameState.startingPoint.y - radius,
                width: radius * 2,
                height: radius * 2
            )

            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)

            context.restoreGState()
        }

        private func drawPauseIndicator(in context: CGContext, rect: CGRect) {
            context.saveGState()

            context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
            context.fill(rect)

            let centerX = rect.width / 2
            let centerY = rect.height / 2
            let barWidth: CGFloat = 15
            let barHeight: CGFloat = 40
            let spacing: CGFloat = 10

            context.setFillColor(UIColor.white.cgColor)

            let leftBar = CGRect(
                x: centerX - spacing / 2 - barWidth,
                y: centerY - barHeight / 2,
                width: barWidth,
                height: barHeight
            )
            context.fill(leftBar)

            let rightBar = CGRect(
                x: centerX + spacing / 2,
                y: centerY - barHeight / 2,
                width: barWidth,
                height: barHeight
            )
            context.fill(rightBar)

            let text = "Touch to continue"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
            let attributedText = NSAttributedString(string: text, attributes: textAttributes)
            let textSize = attributedText.size()
            let textRect = CGRect(
                x: centerX - textSize.width / 2,
                y: centerY + barHeight / 2 + 20,
                width: textSize.width,
                height: textSize.height
            )
            attributedText.draw(in: textRect)

            context.restoreGState()
        }
    }
}

// Gesture recognizer delegate
extension GameCanvasView.DrawingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer.view is UIScrollView {
            return false
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view is UIScrollView {
            return true
        }
        return false
    }
}
