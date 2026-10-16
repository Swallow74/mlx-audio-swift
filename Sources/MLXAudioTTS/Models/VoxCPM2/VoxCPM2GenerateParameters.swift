//
//  VoxCPM2GenerateParameters.swift
//  MLXAudio
//

import Foundation

/// Generation parameters specific to VoxCPM2.
///
/// These supplement the standard `GenerateParameters` (temperature, topP,
/// maxTokens) from MLXLMCommon with the settings that drive VoxCPM2's CFM
/// diffusion decoder, which `GenerateParameters` cannot express.
///
/// Every field is optional: `nil` means "use the value from the model config"
/// (`inference_timesteps`, `cfg_scale`), so `VoxCPM2GenerateParameters()` gives
/// exactly the same behaviour as the plain protocol call.
public struct VoxCPM2GenerateParameters: Sendable {
    // MARK: - Diffusion

    /// Number of CFM diffusion timesteps per audio patch.
    ///
    /// Default: the model config's `inference_timesteps` (10). This is the only
    /// real latency/speed lever VoxCPM2 has — everything else is fixed work.
    /// Lower values trade a little timbre quality for speed: 4 is roughly twice
    /// as fast as 10 but a faint noise floor becomes audible on some voices,
    /// 6 is a good balance. Range: 4-20.
    public var inferenceTimesteps: Int?

    /// Classifier-free guidance scale.
    ///
    /// Default: the model config's `cfg_scale` (2.0). Keep the default: `0`
    /// stops the model from ever predicting its stop token (it then emits
    /// filler up to `maxTokens`), and `1.0` produces a hissier voice than the
    /// default. `2.0` and `3.0` sound equivalent.
    public var cfgValue: Float?

    // MARK: - Sampling

    /// Optional RNG seed, for reproducible output.
    public var seed: UInt64?

    public init(
        inferenceTimesteps: Int? = nil,
        cfgValue: Float? = nil,
        seed: UInt64? = nil
    ) {
        self.inferenceTimesteps = inferenceTimesteps
        self.cfgValue = cfgValue
        self.seed = seed
    }

    // MARK: - Presets

    /// Fewest diffusion steps: fastest, with a slightly noisier timbre.
    public static var fast: VoxCPM2GenerateParameters {
        VoxCPM2GenerateParameters(inferenceTimesteps: 4)
    }

    /// Recommended speed/quality balance.
    public static var balanced: VoxCPM2GenerateParameters {
        VoxCPM2GenerateParameters(inferenceTimesteps: 6)
    }

    /// The model default: 10 diffusion steps.
    public static var highQuality: VoxCPM2GenerateParameters {
        VoxCPM2GenerateParameters(inferenceTimesteps: 10)
    }
}
