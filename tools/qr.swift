// Statik QR ureticisi (poster vb. icin).
// Kullanim: swift tools/qr.swift "https://..." cikti.png [piksel]
import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO
import Foundation
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count >= 3 else {
  print("kullanim: swift qr.swift <metin> <cikti.png> [piksel=1024]"); exit(1)
}
let text = args[1]
let out = args[2]
let size = args.count > 3 ? Int(args[3]) ?? 1024 : 1024

let filter = CIFilter.qrCodeGenerator()
filter.message = Data(text.utf8)
filter.correctionLevel = "M"
guard let img = filter.outputImage else { print("qr uretilemedi"); exit(1) }

let scale = CGFloat(size) / img.extent.width
let scaled = img.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
let ctx = CIContext()
guard let cg = ctx.createCGImage(scaled, from: scaled.extent) else {
  print("cg uretilemedi"); exit(1)
}
let dest = CGImageDestinationCreateWithURL(
  URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, cg, nil)
CGImageDestinationFinalize(dest)
print("wrote \(out) (\(size)px)")
