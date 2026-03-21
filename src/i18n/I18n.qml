pragma Singleton

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton
{
    readonly property string homeDir: StandardPaths.writableLocation(
        StandardPaths.HomeLocation
    )
    readonly property string language: Config.config.language
    readonly property string baseLanguage: normalizeLanguage(language)

    property var _bundledBase: parseJson(bundledBaseFile.text())
    property var _userBase: parseJson(userBaseFile.text())
    property var _bundledEn: parseJson(bundledEnFile.text())

    property var _currentBundle: {
        if (hasKeys(_userBase)) return _userBase
        if (hasKeys(_bundledBase)) return _bundledBase
        return _bundledEn
    }

    function normalizeLanguage(code) {
        if (!code) return "en"
        const lowered = code.toLowerCase()
        const parts = lowered.split(/[-_\s,]+/)
        const primary = parts.find(part => part.length > 0)
        return primary && primary.length > 0 ? primary : "en"
    }

    function filePath(url) {
        const value = Qt.resolvedUrl(url).toString()
        return value.startsWith("file://") ? value.slice("file://".length) : value
    }

    function parseJson(text) {
        try {
            return JSON.parse(text)
        } catch (e) {
            return {}
        }
    }

    function hasKeys(obj) {
        return obj && Object.keys(obj).length > 0
    }

    function lookup(bundle, key) {
        const parts = key.split(".")
        let node = bundle
        for (const part of parts) {
            if (!node || typeof node !== "object" || !(part in node)) return null
            node = node[part]
        }
        return typeof node === "string" ? node : null
    }

    function format(template, args) {
        if (!args || args.length === 0) return template
        let result = template
        for (let i = 0; i < args.length; i++) {
            const key = "%" + (i + 1)
            result = result.split(key).join(args[i])
        }
        return result
    }

    function t(key, ...args) {
        const template = lookup(_currentBundle, key) || key
        return format(template, args)
    }

    FileView {
        id: bundledEnFile
        path: filePath("en.json")
    }

    FileView {
        id: bundledBaseFile
        path: filePath(`${baseLanguage}.json`)
    }

    FileView {
        id: userBaseFile
        path: filePath(`${Config.path}/i18n/${baseLanguage}.json`)
    }
}
