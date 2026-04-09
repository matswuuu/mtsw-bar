pragma Singleton

import Quickshell
import Quickshell.Io
import QtCore
import QtQuick

Singleton {
    id: root

    readonly property string homeDir: StandardPaths.writableLocation(
        StandardPaths.HomeLocation
    )
    readonly property string path: homeDir + "/.config/mtsw-bar"

    property var config: {
        const defaultConfig = {
            language: "en",
            monitors: [],
            bar: {
                tray: {
                    colorization: 1,
                    colorizationColor: "#ffffff",
                    iconOrder: []
                },
                sound: {
                    titleLength: 32,
                    artistLength: 16
                },
                network: {
                    hosts: [
                        {
                            host: " ",
                            pingCommand: "nc -w 5 -uvz $HOST 443"
                        },
                        {
                            host: " ",
                            pingCommand: "nc -w 5 -uvz $HOST 44443"
                        }
                    ]
                }
            }
        }

        try {
            const text = configFile.text()
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
        path: `${root.path}/config.json`
    }
}
