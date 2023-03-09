//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation
import Yams

public class ConfigManager {
    let env : EnvironmentType
    var baseConfig : BaseConfigModel
    var envConfig : EnvConfig.Environment
    public init(environment: EnvironmentType) {
        let baseConfigData = Helpers.getDataFromFile(fileName: "BaseConfig", type: "yaml")!
        baseConfig = try! YAMLDecoder().decode(BaseConfigModel.self, from: baseConfigData)

        let envConfigData = Helpers.getDataFromFile(fileName: "EnvConfig", type: "yaml")!
        let envConfigs = try! YAMLDecoder().decode(EnvConfig.self, from: envConfigData)

        if environment == .dev {
            envConfig = envConfigs.dev
        } else {
            envConfig = envConfigs.prod
        }
        self.env = environment
    }
}
