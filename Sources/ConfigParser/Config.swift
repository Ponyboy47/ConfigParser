open class Config: INIConfig {
    /// The section key relating to global elements
    public static let GlobalsKey = "GLOBALS"
    /// The section key relating to the default elements
    public static let DefaultsKey = "DEFAULTS"

    /// Section containing the default values
    public var defaults: ConfigSection = [:]
    /// Section containing the global values
    public var globals: ConfigSection = [:]
    /// Underlying storage of the Config
    public var _dict: [Key: Value] = [:]

    /// Empty initializer
    public required init() {}
}
