pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property ListModel entries: ListModel {}
    signal historyChanged()

    property string _lastClipText: ""

    Settings {
        id: settings
        category: "clipboard"
        property var pinnedTexts: []
    }

    Process {
        id: storeProc
        command: ["sh", "-c", "wl-paste --watch cliphist store 2>/dev/null"]
        running: true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (!listProc.running) listProc.running = true
        }
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root._onList(this.text.trim())
        }
    }

    property var _decodeQueue: []

    Process {
        id: decodeProc
        property int decodeId: -1
        property bool isImageDecode: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: root._onDecode(this.text.trim())
        }
    }

    Process {
        id: copyProc
        command: ["wl-copy"]
        stdinEnabled: true
        property string pendingText: ""
        onStarted: {
            if (pendingText) {
                write(pendingText)
                pendingText = ""
                stdinEnabled = false
            }
        }
        onRunningChanged: {
            if (!running) stdinEnabled = true
        }
    }

    Process {
        id: imageCopyProc
        command: []
    }

    Process {
        id: deleteProc
        command: []
    }

    Process {
        id: cleanupProc
        command: []
    }

    Component.onCompleted: {
        var pinned = settings.pinnedTexts || []
        for (var i = pinned.length - 1; i >= 0; i--) {
            var text = pinned[i]
            if (typeof text === "string" && text.indexOf("__IMG__:") === 0) {
                var segs = text.substring(7).split("|")
                entries.append({
                    cliphistId: -1,
                    text: "",
                    pinned: true,
                    isImage: true,
                    imagePath: segs[0] || ""
                })
            } else {
                entries.append({
                    cliphistId: -1,
                    text: text,
                    pinned: true,
                    isImage: false,
                    imagePath: ""
                })
            }
        }
        listProc.running = true
    }

    function _isImagePreview(preview) {
        return preview.indexOf("[[ binary data ") === 0
    }

    function _onList(output) {
        if (!output) { _cleanup([]); historyChanged(); return }
        var lines = output.split('\n')
        var activeIds = []
        _decodeQueue = []

        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].split('\t')
            var id = parseInt(parts[0])
            if (isNaN(id)) continue
            activeIds.push(id)

            var found = false
            for (var j = 0; j < entries.count; j++) {
                if (entries.get(j).cliphistId === id) { found = true; break }
            }
            if (!found) {
                var preview = parts.slice(1).join('\t')
                _decodeQueue.push({ id: id, isImage: _isImagePreview(preview) })
            }
        }

        _cleanup(activeIds)
        _cleanImageFiles(activeIds)

        if (_decodeQueue.length > 0) _decodeNext()
        else historyChanged()
    }

    function _decodeNext() {
        if (_decodeQueue.length === 0) { historyChanged(); return }
        var item = _decodeQueue.shift()
        decodeProc.decodeId = item.id
        decodeProc.isImageDecode = item.isImage
        if (item.isImage) {
            decodeProc.command = ["sh", "-c",
                "(cliphist decode " + item.id + " 2>/dev/null > /tmp/cliphist_" + item.id + ".png && echo OK) || rm -f /tmp/cliphist_" + item.id + ".png"]
        } else {
            decodeProc.command = ["sh", "-c",
                "cliphist decode " + item.id + " 2>/dev/null | head -c 50000 | iconv -f UTF-8 -t UTF-8//IGNORE"]
        }
        decodeProc.running = true
    }

    function _onDecode(text) {
        var id = decodeProc.decodeId
        var isImage = decodeProc.isImageDecode
        if (isImage) {
            if (text === "OK" && id >= 0) {
                var found = false
                for (var i = 0; i < entries.count; i++) {
                    if (entries.get(i).cliphistId === id) { found = true; break }
                }
                if (!found) {
                    entries.insert(0, {
                        cliphistId: id,
                        text: "",
                        pinned: false,
                        isImage: true,
                        imagePath: "/tmp/cliphist_" + id + ".png"
                    })
                }
            }
        } else if (text && id >= 0) {
            var found = false
            for (var i = 0; i < entries.count; i++) {
                if (entries.get(i).cliphistId === id || entries.get(i).text === text) {
                    if (entries.get(i).cliphistId !== id)
                        entries.setProperty(i, "cliphistId", id)
                    found = true
                    break
                }
            }
            if (!found) {
                _lastClipText = text
                entries.insert(0, { cliphistId: id, text: text, pinned: false, isImage: false, imagePath: "" })
            }
        }
        _decodeNext()
    }

    function _cleanup(activeIds) {
        for (var i = entries.count - 1; i >= 0; i--) {
            var e = entries.get(i)
            if (!e.pinned && activeIds.indexOf(e.cliphistId) < 0) {
                entries.remove(i)
            }
        }
    }

    function _cleanImageFiles(activeIds) {
        var toRemove = []
        for (var i = 0; i < entries.count; i++) {
            var e = entries.get(i)
            if (e.isImage && e.imagePath && activeIds.indexOf(e.cliphistId) < 0 && !e.pinned)
                toRemove.push(e.imagePath)
        }
    }

    function copyToClipboard(index) {
        if (index < 0 || index >= entries.count) return
        var e = entries.get(index)
        if (e.isImage) {
            if (e.cliphistId >= 0) {
                imageCopyProc.command = ["sh", "-c",
                    "cliphist decode " + e.cliphistId + " 2>/dev/null | wl-copy --type image/png 2>/dev/null"]
            } else if (e.imagePath) {
                imageCopyProc.command = ["sh", "-c",
                    "wl-copy --type image/png < " + e.imagePath + " 2>/dev/null"]
            }
            imageCopyProc.running = true
        } else {
            _lastClipText = e.text
            copyProc.stdinEnabled = true
            copyProc.pendingText = e.text
            copyProc.running = true
        }
    }

    function togglePin(index) {
        if (index < 0 || index >= entries.count) return
        var e = entries.get(index)
        var pinned = !e.pinned
        entries.setProperty(index, "pinned", pinned)
        if (!pinned && e.cliphistId < 0) {
            entries.remove(index)
        }
        savePinned()
        historyChanged()
    }

    function removeEntry(index) {
        if (index < 0 || index >= entries.count) return
        var e = entries.get(index)
        if (e.cliphistId >= 0) {
            deleteProc.command = ["cliphist", "delete", String(e.cliphistId)]
            deleteProc.running = true
        }
        entries.remove(index)
        savePinned()
        historyChanged()
    }

    function clearHistory() {
        var ids = []
        for (var i = entries.count - 1; i >= 0; i--) {
            if (!entries.get(i).pinned) {
                var e = entries.get(i)
                if (e.cliphistId >= 0)
                    ids.push(e.cliphistId)
                entries.remove(i)
            }
        }
        if (ids.length > 0) {
            deleteProc.command = ["sh", "-c", ids.map(function(id) {
                return "cliphist delete " + id
            }).join(" && ")]
            deleteProc.running = true
        }
        savePinned()
        historyChanged()
    }

    function savePinned() {
        var pinned = []
        for (var i = 0; i < entries.count; i++) {
            var e = entries.get(i)
            if (e.pinned) {
                if (e.isImage) {
                    pinned.push("__IMG__:" + e.imagePath + "|" + e.cliphistId)
                } else {
                    pinned.push(e.text)
                }
            }
        }
        settings.pinnedTexts = pinned
    }
}
