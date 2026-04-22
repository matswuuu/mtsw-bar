import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell
import qs.theme
import qs.services.network

Item {
    readonly property var theme: Themes.active
    readonly property bool wifiEnabled: Network.type === NetworkType.WIFI

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "󰖩"
                
                font.pixelSize: 24
                color: wifiEnabled
                    ? theme.interactiveColor
                    : theme.interactiveColor
            }

            Text {
                text: "Wi-Fi Networks"
                font.pixelSize: 18
                font.bold: true
                Layout.fillWidth: true
                color: theme.interactiveColor
            }

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 26
                radius: height / 2
                color: wifiEnabled
                    ? theme.interactiveColor
                    : theme.interactiveColor

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    y: 3
                    x: wifiEnabled
                        ? parent.width - width - 3
                        : 3
                    color: theme.backgroundColor

                    Behavior on x { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Network.toggleWifi()
                }
            }

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 8

                color: refreshMouseArea.containsMouse
                    ? theme.interactiveColor
                    : theme.interactiveColor

                Text {
                    id: wifiScanIcon
                    anchors.centerIn: parent
                    text: "󰑐"
                    
                    font.pixelSize: 20
                    color: Services.Network.scanning
                        ? theme.interactiveColor
                        : theme.interactiveColor

                    RotationAnimator on rotation {
                        from: 0; to: 360
                        duration: 900
                        loops: Animation.Infinite
                        running: Services.Network.scanning
                    }
                }

                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Network.rescan()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: messageText.visible ? 40 : 0
            visible: messageText.visible
            radius: 8

            color: Services.Network.lastErrorMessage !== ""
                ? theme.red
                : theme.primary

            border.color: Services.Network.lastErrorMessage !== ""
                ? theme.red
                : theme.primary

            border.width: 1

            Text {
                id: messageText
                anchors.centerIn: parent

                text: Services.Network.lastErrorMessage !== ""
                    ? Services.Network.lastErrorMessage
                    : (Services.Network.message === "ok"
                        ? "Connected successfully!"
                        : "")

                visible: text !== ""

                color: Services.Network.lastErrorMessage !== ""
                    ? theme.error
                    : theme.error

                font.pixelSize: 13
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 150 }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Services.Network.active ? 70 : 0
            visible: Services.Network.active
            radius: 10

            color: theme.backgroundColor
            border.color: theme.primary
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Text {
                //     text: Services.Network.icon
                //     
                //     font.pixelSize: 26
                //     color: theme.primary
                // }

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        text: Services.Network.active
                            ? Services.Network.active.name
                            : ""
                        font.bold: true
                        color: theme.backgroundColor
                    }

                    Text {
                        text: "Connected"
                        font.pixelSize: 12
                        color: theme.primary
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 32
                    radius: 6

                    color: disconnectMouseArea.containsMouse
                        ? theme.primary
                        : theme.backgroundColor

                    border.color: theme.primary
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Disconnect"
                        color: disconnectMouseArea.containsMouse
                            ? theme.primary
                            : theme.primary
                    }

                    MouseArea {
                        id: disconnectMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Services.Network.disconnect()
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: theme.backgroundColor

            ScrollView {
                anchors.fill: parent
                anchors.margins: 6

                ColumnLayout {
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: Services.Network.connections
                            .filter(c => c.type === "wifi")
                            .sort((a, b) => {
                            if (a.active && !b.active) return -1
                            if (!a.active && b.active) return 1
                            return b.strength - a.strength
                        })

                        delegate: Rectangle {
                            id: netItem
                            Layout.fillWidth: true
                            Layout.preferredHeight: isConnecting ? 64 : 56
                            radius: 8

                            property bool isConnecting: Services.Network.connecting
                                && modelData.name === Services.Network.lastNetworkAttempt

                            color: networkMouseArea.containsMouse
                                ? theme.backgroundColor
                                : "transparent"

                            Behavior on Layout.preferredHeight {
                                NumberAnimation { duration: 150 }
                            }

                            MouseArea {
                                id: networkMouseArea
                                anchors.fill: parent
                                hoverEnabled: true

                                onClicked: {
                                    if (!modelData.active && !isConnecting) {
                                        passwordDialog.targetNetwork = modelData
                                        if (modelData.isSecure && !modelData.saved)
                                            passwordDialog.visible = true
                                        else
                                            Services.Network.connect(modelData, "")
                                    }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12

                                Item {
                                    width: 28
                                    height: 28

                                    Text {
                                        id: netIcon
                                        anchors.centerIn: parent
                                        
                                        font.pixelSize: 22
                                        text: {
                                            if (isConnecting) return "󰑐"
                                            if (modelData.active) return "󰄬"
                                            const s = modelData.strength
                                            if (s >= 75) return "󰤨"
                                            if (s >= 50) return "󰤥"
                                            if (s >= 25) return "󰤢"
                                            return "󰤟"
                                        }
                                        color: (isConnecting || modelData.active)
                                            ? theme.primary
                                            : theme.backgroundColor

                                        RotationAnimator on rotation {
                                            from: 0; to: 360
                                            duration: 900
                                            loops: Animation.Infinite
                                            running: isConnecting
                                        }
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: modelData.name
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        color: theme.backgroundColor
                                    }

                                    Text {
                                        visible: isConnecting
                                        text: "Connecting..."
                                        font.pixelSize: 11
                                        color: theme.primary
                                    }
                                }

                                Rectangle {
                                    visible: modelData.saved && !isConnecting
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    radius: 6
                                    z: 1
                                    color: forgetMouseArea.containsMouse
                                        ? theme.error
                                        : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰺝"
                                        
                                        font.pixelSize: 16
                                        color: forgetMouseArea.containsMouse
                                            ? theme.error
                                            : theme.backgroundColor_variant
                                    }

                                    MouseArea {
                                        id: forgetMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mouse => {
                                            mouse.accepted = true
                                            Services.Network.forget(modelData.name)
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: passwordDialog
        anchors.fill: parent
        visible: false

        color: theme.yellow
        opacity: 0.85

        property var targetNetwork: null

        Rectangle {
            anchors.centerIn: parent
            width: 320
            height: 220
            radius: 12
            color: theme.backgroundColor
            border.color: theme.primary
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                Text {
                    text: "Enter Password"
                    font.bold: true
                    font.pixelSize: 16
                    color: theme.backgroundColor
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 6
                    color: theme.backgroundColor
                    border.color: passwordInput.activeFocus
                        ? theme.primary
                        : theme.backgroundColor
                    border.width: passwordInput.activeFocus ? 2 : 1

                    FocusScope {
                        focus: passwordDialog.visible
                        id: inputScope
                        anchors.fill: parent
                        TextField {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.margins: 10
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Normal
                            color: theme.backgroundColor
                            selectionColor: theme.primary
                            selectedTextColor: theme.primary
                            font.pixelSize: 14
                            placeholderText: "Enter Password"
                            focus: true
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 8
                        color: cancelMouseArea.containsMouse
                            ? theme.backgroundColor
                            : theme.backgroundColor2
                        border.color: theme.yellow
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: theme.backgroundColor
                        }

                        MouseArea {
                            id: cancelMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                passwordDialog.visible = false
                                passwordInput.text = ""
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 8
                        color: theme.primary

                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: theme.primary
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Services.Network.connect(
                                    passwordDialog.targetNetwork,
                                    passwordInput.text
                                )
                                passwordDialog.visible = false
                                passwordInput.text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}