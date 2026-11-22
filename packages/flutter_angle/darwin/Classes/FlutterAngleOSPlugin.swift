#if os(macOS)
import FlutterMacOS
#elseif os(iOS)
import Flutter
#endif

@objc public class FlutterAngleOSPlugin: NSObject{
  private var textureRegistry: FlutterTextureRegistry?

  private var textures: IOSurfaceRef?
  private var textureToPixelBuffer: Unmanaged<CVPixelBuffer>?

  private var width: Int = 0
  private var height: Int = 0

  public var textureId: Int64 = -1;
  
  init(textureRegistry: FlutterTextureRegistry?){
    self.textureRegistry = textureRegistry;
    super.init();
    self.textureId = textureRegistry?.register(self) ?? -1
  }

  public func textureFrameAvailable(result: @escaping FlutterResult) {
    guard textures != nil else {
      result(FlutterError(code: "INVALID_TEXTURE_ID", message: "Unknown texture ID", details: nil))
      return
    }
    // Notify the Flutter texture registry that a new frame is available
    textureRegistry?.textureFrameAvailable(self.textureId)
    result(nil)
  }

  // MARK: - Texture Creation
  public func createTexture(width: Int, height: Int, result: @escaping FlutterResult) {
    self.width = width
    self.height = height

    // Create IOSurface
    NSLog("Creating texture with physical dimensions: \(width) x \(height)")

    // Configure IOSurface properties
    let pixelFormat = kCVPixelFormatType_32BGRA
    let bytesPerElement = 4
    let bytesPerRow = IOSurfaceAlignProperty(kIOSurfaceBytesPerRow, width * bytesPerElement)
    let totalBytes = IOSurfaceAlignProperty(kIOSurfaceAllocSize, bytesPerRow * height)

    let options: [String: Any] = [
      kIOSurfaceWidth as String: width,
      kIOSurfaceHeight as String: height,
      kIOSurfacePixelFormat as String: pixelFormat,
      kIOSurfaceBytesPerElement as String: bytesPerElement,
      kIOSurfaceBytesPerRow as String: bytesPerRow,
      kIOSurfaceAllocSize as String: totalBytes
    ]

    // Create the IOSurface
    let ioSurface = IOSurfaceCreate(options as CFDictionary)
    if ioSurface == nil {
      result(FlutterError(code: "IOSURFACE_ERROR", message: "Failed to create IOSurface", details: nil))
      return
    }
      
    if !createPixelBufferFromIOSurface(ioSurface!) {
      result(FlutterError(code: "PIXELBUFFER_ERROR", message: "Failed to create CVPixelBuffer", details: nil))
      return
    }
      
    // Store in our texture maps
    textures = ioSurface!
    // Convert the pointer to UInt64 for safe passage through Flutter codec
    let surfacePointer = UInt64(bitPattern: Int64(Int(bitPattern: Unmanaged.passUnretained(ioSurface!).toOpaque())))

    result([
      "textureId": textureId,
      "surfacePointer": surfacePointer
    ])
  }

  public func resizeTexture(width: Int, height: Int, result: @escaping FlutterResult) {
    textures = nil
        
    textureToPixelBuffer?.release()
    textureToPixelBuffer = nil
    createTexture(width: width, height: height, result: result)
  }

  public func disposeTexture() {
    if let tr = textureRegistry {
      tr.unregisterTexture(textureId)
    }
    
    // Clean up our maps
    textures = nil
      
    textureToPixelBuffer?.release()
    textureToPixelBuffer = nil
      
    textureRegistry = nil
  }
    
  // MARK: - IOSurface Access
  public func getIOSurfaceHandle(result: @escaping FlutterResult) {
    guard let surface = textures else {
      result(FlutterError(code: "NO_IOSURFACE", message: "No IOSurface available for this texture ID", details: nil))
      return
    }
    
    // Return the IOSurface ID (not the pointer itself) for safety
    let surfaceID = IOSurfaceGetID(surface)
    result(surfaceID)
  }
    
  private func createPixelBufferFromIOSurface(_ surface: IOSurfaceRef) -> Bool {
    guard CVPixelBufferCreateWithIOSurface(
      kCFAllocatorDefault,
      surface,
      [kCVPixelBufferMetalCompatibilityKey: true] as CFDictionary,
      &textureToPixelBuffer
    ) == kCVReturnSuccess 
    else{
      print("CVPixelBuffer is nil")
      return false
    }
    
    return true
  }
}

extension FlutterAngleOSPlugin: FlutterTexture {
  public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    guard textureToPixelBuffer != nil else {
      return nil
    }
    if let pixBuffer = textureToPixelBuffer?.takeUnretainedValue() {
      return Unmanaged.passRetained(pixBuffer)
    }
    return nil
  }
}
