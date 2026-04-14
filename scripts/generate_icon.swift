import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

let context = NSGraphicsContext.current!.cgContext

// Background gradient - professional blue
let colorSpace = CGColorSpaceCreateDeviceRGB()
let gradientColors = [
    CGColor(red: 0.14, green: 0.30, blue: 0.55, alpha: 1.0),
    CGColor(red: 0.22, green: 0.45, blue: 0.72, alpha: 1.0)
] as CFArray
let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 1.0])!
context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 1024, y: 0), options: [])

// Shield shape
let shieldPath = NSBezierPath()
let cx: CGFloat = 512
let cy: CGFloat = 480
let sw: CGFloat = 360
let sh: CGFloat = 440

shieldPath.move(to: NSPoint(x: cx, y: cy + sh * 0.5))
shieldPath.curve(to: NSPoint(x: cx - sw * 0.5, y: cy + sh * 0.25),
                 controlPoint1: NSPoint(x: cx - sw * 0.3, y: cy + sh * 0.48),
                 controlPoint2: NSPoint(x: cx - sw * 0.5, y: cy + sh * 0.4))
shieldPath.line(to: NSPoint(x: cx - sw * 0.5, y: cy + sh * 0.05))
shieldPath.curve(to: NSPoint(x: cx, y: cy - sh * 0.5),
                 controlPoint1: NSPoint(x: cx - sw * 0.5, y: cy - sh * 0.25),
                 controlPoint2: NSPoint(x: cx - sw * 0.15, y: cy - sh * 0.45))
shieldPath.curve(to: NSPoint(x: cx + sw * 0.5, y: cy + sh * 0.05),
                 controlPoint1: NSPoint(x: cx + sw * 0.15, y: cy - sh * 0.45),
                 controlPoint2: NSPoint(x: cx + sw * 0.5, y: cy - sh * 0.25))
shieldPath.line(to: NSPoint(x: cx + sw * 0.5, y: cy + sh * 0.25))
shieldPath.curve(to: NSPoint(x: cx, y: cy + sh * 0.5),
                 controlPoint1: NSPoint(x: cx + sw * 0.5, y: cy + sh * 0.4),
                 controlPoint2: NSPoint(x: cx + sw * 0.3, y: cy + sh * 0.48))
shieldPath.close()

NSColor(white: 1.0, alpha: 0.15).setFill()
shieldPath.fill()
NSColor(white: 1.0, alpha: 0.3).setStroke()
shieldPath.lineWidth = 3
shieldPath.stroke()

// Pen / pencil icon inside shield
let penBody = NSBezierPath()
// Pen barrel - angled
let penCx: CGFloat = 512
let penCy: CGFloat = 460
let angle: CGFloat = .pi / 6 // 30 degrees tilt

// Draw a stylized pen
context.saveGState()
context.translateBy(x: penCx, y: penCy)
context.rotate(by: -angle)

// Pen body
let bodyRect = NSRect(x: -25, y: -120, width: 50, height: 200)
let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: 8, yRadius: 8)
NSColor.white.setFill()
bodyPath.fill()

// Pen tip
let tipPath = NSBezierPath()
tipPath.move(to: NSPoint(x: -20, y: -120))
tipPath.line(to: NSPoint(x: 0, y: -170))
tipPath.line(to: NSPoint(x: 20, y: -120))
tipPath.close()
NSColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 1.0).setFill()
tipPath.fill()

// Pen clip
let clipRect = NSRect(x: -8, y: 80, width: 16, height: 50)
let clipPath = NSBezierPath(roundedRect: clipRect, xRadius: 4, yRadius: 4)
NSColor(white: 0.85, alpha: 1.0).setFill()
clipPath.fill()

// Pen band
let bandRect = NSRect(x: -28, y: 60, width: 56, height: 12)
let bandPath = NSBezierPath(roundedRect: bandRect, xRadius: 3, yRadius: 3)
NSColor(red: 0.18, green: 0.35, blue: 0.58, alpha: 1.0).setFill()
bandPath.fill()

context.restoreGState()

// Writing lines (to suggest composition)
NSColor(white: 1.0, alpha: 0.4).setStroke()
for i in 0..<3 {
    let y: CGFloat = 280 + CGFloat(i) * 30
    let linePath = NSBezierPath()
    let startX: CGFloat = 380 + CGFloat(i) * 20
    let endX: CGFloat = 680 - CGFloat(i) * 30
    linePath.move(to: NSPoint(x: startX, y: y))
    linePath.line(to: NSPoint(x: endX, y: y))
    linePath.lineWidth = 3
    linePath.lineCapStyle = .round
    linePath.stroke()
}

image.unlockFocus()

// Save as PNG
guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("ERROR: Failed to generate PNG")
    exit(1)
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.png"
let url = URL(fileURLWithPath: outputPath)
try! pngData.write(to: url)
print("Icon saved to \(outputPath)")
