pragma Singleton

import Quickshell
import Quickshell.Io
import QtCore
import QtQuick

Singleton {
    readonly property string homeDir: StandardPaths.writableLocation(
        StandardPaths.HomeLocation
    )

    property var config: {
        const defaultConfig = {
            monitors: [],
            bar: {
                tray: {
                    iconOrder: []
                }
            }
        }

        const text = configFile.text()

        try {
            const parsed = JSON.parse(text)
            return mergeDefaults(defaultConfig, parsed)
        } catch (e) {
            return defaultConfig
        }
    }

    function mergeDefaults(defaults, obj) {
        var result = {}

        for (var key in defaults) {
            if (defaults.hasOwnProperty(key)) {
                if (
                    defaults[key] !== null &&
                    typeof defaults[key] === "object" &&
                    !Array.isArray(defaults[key])
                ) {
                    result[key] = mergeDefaults(defaults[key], {})
                } else {
                    result[key] = defaults[key]
                }
            }
        }

        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (
                    obj[key] !== null &&
                    typeof obj[key] === "object" &&
                    !Array.isArray(obj[key])
                ) {
                    result[key] = mergeDefaults(result[key] || {}, obj[key])
                } else {
                    result[key] = obj[key]
                }
            }
        }

        return result
    }

FileView {
        id: configFile
        path: homeDir + "/.config/mtsw-bar/config.json"
    }
}
