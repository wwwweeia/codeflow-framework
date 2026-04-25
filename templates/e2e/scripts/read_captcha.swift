#!/usr/bin/env swift

import Foundation
import Vision
import AppKit

enum CaptchaError: Error {
  case invalidArguments
  case imageLoadFailed
  case recognitionFailed
  case noCandidate
}

func normalize(_ text: String) -> String {
  let upper = text.uppercased()
  let filtered = upper.unicodeScalars.filter { scalar in
    CharacterSet.alphanumerics.contains(scalar)
  }
  return String(String.UnicodeScalarView(filtered))
}

let args = CommandLine.arguments
guard args.count >= 2 else {
  fputs("Usage: read_captcha.swift <image-path>\n", stderr)
  exit(1)
}

let imagePath = args[1]
guard let image = NSImage(contentsOfFile: imagePath),
      let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let cgImage = bitmap.cgImage else {
  fputs("Failed to load image: \(imagePath)\n", stderr)
  exit(2)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.usesLanguageCorrection = false
request.recognitionLanguages = ["en-US"]
request.minimumTextHeight = 0.2

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

do {
  try handler.perform([request])
  let observations = request.results ?? []
  var candidates: [String] = []

  for observation in observations {
    for recognized in observation.topCandidates(5) {
      let normalized = normalize(recognized.string)
      if normalized.isEmpty {
        continue
      }
      candidates.append(normalized)
      if normalized.count == 4 {
        print(normalized)
        exit(0)
      }
    }
  }

  if let best = candidates
    .sorted(by: { lhs, rhs in
      let lhsScore = abs(lhs.count - 4)
      let rhsScore = abs(rhs.count - 4)
      if lhsScore == rhsScore {
        return lhs < rhs
      }
      return lhsScore < rhsScore
    })
    .first {
    print(best)
    exit(0)
  }

  throw CaptchaError.noCandidate
} catch {
  fputs("OCR failed for image: \(imagePath)\n", stderr)
  exit(3)
}
