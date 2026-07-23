import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.element
import qs.theme
import qs.services.clipboard

PanelWindow {
    id: root
    required property var screen

    anchors { top: true; left: true; right: true; bottom: true }
    exclusiveZone: -1
    color: "transparent"
    visible: false
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property var theme: Themes.active

    ListModel { id: displayModel }

    function rebuildDisplay(resetPosition) {
        displayModel.clear()
        _selectedIndex = -1
        listView.currentIndex = -1
        var q = searchField.text.toLowerCase().trim()

        var pinnedItems = []
        var unpinnedItems = []
        for (var i = 0; i < ClipboardService.entries.count; i++) {
            var e = ClipboardService.entries.get(i)
            if (q && !e.text.toLowerCase().includes(q)) continue
            var item = { text: e.text, pinned: e.pinned, index: i, isSeparator: false, isImage: e.isImage || false, imagePath: e.imagePath || "" }
            if (e.pinned) pinnedItems.push(item)
            else unpinnedItems.push(item)
        }

        for (var j = 0; j < pinnedItems.length; j++) {
            displayModel.append(pinnedItems[j])
        }
        if (pinnedItems.length > 0 && unpinnedItems.length > 0) {
            displayModel.append({ text: "", pinned: false, index: -1, isSeparator: true, isImage: false, imagePath: "" })
        }
        for (var k = 0; k < unpinnedItems.length; k++) {
            displayModel.append(unpinnedItems[k])
        }

        if (resetPosition && displayModel.count > 0) {
            listView.contentY = 0
        }
    }

    function syncDisplay() {
        var q = searchField.text.toLowerCase().trim()

        var activeIndices = {}
        for (var i = 0; i < ClipboardService.entries.count; i++) {
            var e = ClipboardService.entries.get(i)
            if (q && !e.text.toLowerCase().includes(q)) continue
            activeIndices[i] = true
        }

        var changed = false
        for (var di = displayModel.count - 1; di >= 0; di--) {
            var dm = displayModel.get(di)
            if (!dm.isSeparator && !activeIndices[dm.index]) {
                displayModel.remove(di)
                changed = true
            }
        }

        for (var si = 0; si < ClipboardService.entries.count; si++) {
            var se = ClipboardService.entries.get(si)
            if (q && !se.text.toLowerCase().includes(q)) continue
            var found = false
            for (var di2 = 0; di2 < displayModel.count; di2++) {
                if (!displayModel.get(di2).isSeparator && displayModel.get(di2).index === si) {
                    found = true
                    break
                }
            }
            if (!found) {
                rebuildDisplay(true)
                return
            }
        }

        if (changed) {
            var sepIdx = -1
            for (var di3 = 0; di3 < displayModel.count; di3++) {
                if (displayModel.get(di3).isSeparator) { sepIdx = di3; break }
            }
            var hasAnyPinned = false
            var hasAnyUnpinned = false
            for (var di4 = 0; di4 < displayModel.count; di4++) {
                if (!displayModel.get(di4).isSeparator) {
                    if (displayModel.get(di4).pinned) hasAnyPinned = true
                    else hasAnyUnpinned = true
                }
            }
            if ((hasAnyPinned && hasAnyUnpinned) && sepIdx < 0) {
                rebuildDisplay(true)
                return
            }
            if ((!hasAnyPinned || !hasAnyUnpinned) && sepIdx >= 0) {
                displayModel.remove(sepIdx)
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            searchField.forceActiveFocus()
            rebuildDisplay(true)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }

    Rectangle {
        id: popup
        width: 400
        height: Math.min(520, root.screen.height * 0.8)
        anchors.centerIn: parent
        radius: 14
        color: theme.backgroundColor2
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.06)

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: theme.backgroundColor
                radius: 14

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: 14

                    RowLayout {
                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 8
                        }
                        spacing: 10

                        Text {
                            text: Icons.search
                            font.family: Icons.font.name
                            font.pixelSize: 20
                            color: theme.textColor2
                        }

                        TextInput {
                            id: searchField
                            Layout.fillWidth: true
                            color: theme.textColor
                            font.pixelSize: 14
                            font.family: theme.font
                            clip: true
                            selectByMouse: true

                            Text {
                                anchors.fill: parent
                                text: "Search clipboard..."
                                color: theme.textColor2
                                font: parent.font
                                visible: parent.text.length === 0
                                verticalAlignment: Text.AlignVCenter
                            }

                            Keys.onPressed: function(event) {
                                switch (event.key) {
                                    case Qt.Key_Escape: root.close(); event.accepted = true; break
                                    case Qt.Key_Up: moveSelection(-1); event.accepted = true; break
                                    case Qt.Key_Down: moveSelection(1); event.accepted = true; break
                                    case Qt.Key_Return:
                                    case Qt.Key_Enter: copySelected(); event.accepted = true; break
                                }
                            }
                            onTextChanged: {
                                if (root.visible) rebuildDisplay(true)
                            }
                        }

                        Text {
                            text: Icons.close
                            font.family: Icons.font.name
                            font.pixelSize: 18
                            color: theme.textColor2
                            visible: searchField.text.length > 0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: searchField.text = ""
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 1
                interactive: true
                boundsBehavior: Flickable.StopAtBounds

                model: displayModel
                currentIndex: -1

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    width: 8
                    contentItem: Rectangle {
                        radius: 4
                        color: theme.textColor2
                        opacity: 0.5
                    }
                    background: Item {}
                }

                Keys.onUpPressed: moveSelection(-1)
                Keys.onDownPressed: moveSelection(1)
                Keys.onReturnPressed: copySelected()
                Keys.onEscapePressed: root.close()

                delegate: Item {
                    id: del
                    required property var model

                    width: ListView.view.width
                    height: model.isSeparator ? 28 : (model.isImage ? 60 : 42)

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: model.isSeparator ? 0 : 3
                        anchors.leftMargin: model.isSeparator ? 0 : 8
                        anchors.rightMargin: model.isSeparator ? 0 : 8
                        radius: model.isSeparator ? 0 : 8
                        color: {
                            if (model.isSeparator) return "transparent"
                            if (del.ListView.isCurrentItem) return Qt.rgba(1, 1, 1, 0.08)
                            return mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.04) : "transparent"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 6
                            spacing: 8
                            visible: !model.isSeparator

                            Text {
                                visible: !model.isImage
                                text: Icons.content_paste
                                font.family: Icons.font.name
                                font.pixelSize: 16
                                color: theme.textColor2
                            }

                            Image {
                                visible: model.isImage
                                source: model.isImage ? "file://" + model.imagePath : ""
                                sourceSize.width: 80
                                sourceSize.height: 48
                                fillMode: Image.PreserveAspectFit
                                clip: true
                            }

                            Text {
                                visible: !model.isImage
                                Layout.fillWidth: true
                                text: model.text
                                color: theme.textColor
                                font.pixelSize: 13
                                font.family: theme.font
                                elide: Text.ElideRight
                                clip: true
                                maximumLineCount: 1
                            }

                            Text {
                                visible: model.isImage
                                text: "Image"
                                color: theme.textColor2
                                font.pixelSize: 12
                                font.family: theme.font
                                font.italic: true
                            }

                            Text {
                                text: model.pinned ? Icons.bookmark : Icons.bookmark_border
                                font.family: Icons.font.name
                                font.pixelSize: 16
                                color: model.pinned ? theme.yellow : theme.textColor2

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (model.index >= 0) {
                                            ClipboardService.togglePin(model.index)
                                            for (var di = 0; di < displayModel.count; di++) {
                                                if (displayModel.get(di).index === model.index) {
                                                    displayModel.setProperty(di, "pinned", !model.pinned)
                                                    break
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "────────── Recent ──────────"
                            color: theme.textColor2
                            font.pixelSize: 11
                            font.family: theme.font
                            opacity: 0.5
                            visible: model.isSeparator
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: model.isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                            onClicked: {
                                if (!model.isSeparator && model.index >= 0) {
                                    ClipboardService.copyToClipboard(model.index)
                                    root.close()
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: theme.backgroundColor
                radius: 14

                Item {
                    Layout.alignment: Qt.AlignCenter
                    implicitHeight: row.implicitHeight
                    implicitWidth: row.implicitWidth

                    RowLayout {
                        id: row
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: Icons.clear_all
                            font.family: Icons.font.name
                            font.pixelSize: 16
                            color: theme.textColor2
                        }

                        Text {
                            text: "Clear History"
                            color: theme.textColor2
                            font.pixelSize: 13
                            font.family: theme.font
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            ClipboardService.clearHistory()
                            rebuildDisplay(true)
                        }
                    }
                }
            }
        }
    }

    property int _selectedIndex: -1

    function moveSelection(delta) {
        var items = []
        for (var i = 0; i < displayModel.count; i++) {
            if (!displayModel.get(i).isSeparator) items.push(i)
        }
        if (items.length === 0) return

        var cur = items.indexOf(_selectedIndex)
        if (cur < 0) cur = delta > 0 ? -1 : items.length

        var next = (cur + delta + items.length) % items.length
        _selectedIndex = items[next]
        listView.currentIndex = _selectedIndex
        listView.positionViewAtIndex(_selectedIndex, ListView.Contain)
    }

    function copySelected() {
        if (_selectedIndex < 0 || _selectedIndex >= displayModel.count) return
        var entry = displayModel.get(_selectedIndex)
        if (entry && entry.index >= 0) {
            ClipboardService.copyToClipboard(entry.index)
            root.close()
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void {
            if (root.visible) {
                root.close()
            } else {
                root.open()
            }
        }
    }

    function open() {
        visible = true
    }

    function close() {
        visible = false
    }
}
