//
//  File.swift
//  
//
//  Created by Ishan Pandey on 3/8/23.
//

import Foundation
import Yams

class CometConfigManager {
    let env : CometEnvironmentType
    var baseConfig : CometBaseConfigModel
    var envConfig : CometEnvConfig.Environment
    init(environment: CometEnvironmentType) {
        let baseConfigData = Helpers.getDataFromFile(fileName: "BaseConfig", type: "yaml")!
        baseConfig = try! YAMLDecoder().decode(CometBaseConfigModel.self, from: baseConfigData)

        let envConfigData = Helpers.getDataFromFile(fileName: "EnvConfig", type: "yaml")!
        let envConfigs = try! YAMLDecoder().decode(CometEnvConfig.self, from: envConfigData)

        if environment == .dev {
            envConfig = envConfigs.dev
        } else {
            envConfig = envConfigs.prod
        }
        self.env = environment
    }
}
