## 16) Короткие примеры реализации (опорные фрагменты)

```swift
// Метры RMS/Peak из аудиотапа
func computeMeters(from buffer: AVAudioPCMBuffer) -> (rms: Float, peak: Float) {
    let ch = buffer.floatChannelData![0]
    let n = Int(buffer.frameLength)
    var sum: Float = 0, peak: Float = -Float.greatestFiniteMagnitude
    vDSP_measqv(ch, 1, &sum, vDSP_Length(n)) // среднеквадратичное
    vDSP_maxv(ch, 1, &peak, vDSP_Length(n))
    let rms = 10 * log10f(sum) // дБFS
    let pk  = 20 * log10f(abs(peak))
    return (rms, pk)
}

// A-B петля (на таймере позиции)
if let a = aPoint, let b = bPoint, position >= b {
    seek(to: a, smooth: true)
}

// Удержание «быстрой» перемотки
holdTimer = DispatchSource.makeTimerSource()
holdTimer?.schedule(deadline: .now(), repeating: .milliseconds(200))
holdTimer?.setEventHandler { [weak self] in self?.nudge(by: direction == .forward ? 2.0 : -2.0) }
holdTimer?.resume()