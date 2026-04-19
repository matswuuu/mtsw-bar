pragma Singleton

import Quickshell
import Quickshell.Io
import QtCore
import QtQuick

Singleton {
    id: root

    readonly property string homeDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)
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
                light: {
                    tapo: {
                        ip: "",
                        email: "",
                        password: "",
                        python: ""
                    }
                },
                network: {
                    updateInterval: 15,
                    hosts: []
                }
            }
        };

        try {
            const text = configFile.text();
            const parsed = JSON.parse(text);
            return mergeDefaults(defaultConfig, parsed);
        } catch (e) {
            return defaultConfig;
        }
    }

    function mergeDefaults(defaults, obj) {
        const result = {};

        for (const key in defaults) {
            if (defaults.hasOwnProperty(key)) {
                if (defaults[key] !== null && typeof defaults[key] === "object" && !Array.isArray(defaults[key])) {
                    result[key] = mergeDefaults(defaults[key], {});
                } else {
                    result[key] = resolveSecrets(defaults[key]);
                }
            }
        }

        for (const key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (obj[key] !== null && typeof obj[key] === "object" && !Array.isArray(obj[key])) {
                    result[key] = mergeDefaults(result[key] || {}, obj[key]);
                } else {
                    result[key] = resolveSecrets(obj[key]);
                }
            }
        }

        return result;
    }

    function isSecretPath(value) {
        return typeof value === "string" && (
            value.startsWith("/") ||
            value.startsWith("./") ||
            value.startsWith("../") ||
            value.startsWith("file://")
        );
    }

    function resolveSecrets(value) {
        if (!isSecretPath(value)) {
            return value;
        }

        try {
            const resolvedPath = value.startsWith("file://") ? value.replace("file://", "") : value;
            const file = secretFileComponent.createObject(null, {
                path: Qt.resolvedUrl(resolvedPath)
            });
            const text = file.text().trim();
            file.destroy();
            return text;
        } catch (e) {
            console.error(`Failed to read secret from ${resolvedPath}: ${e}`);
            return value;
        }
    }

    FileView {
        id: configFile
        path: `${root.path}/config.json`
    }

    Component {
        id: secretFileComponent

        FileView {
            blockLoading: true
        }
    }
}
