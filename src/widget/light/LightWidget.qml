import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.config
import qs.element
import qs.theme
import qs.widget

StyledPopup {
    id: root
    enabled: tapoConfig.ip !== "" && tapoConfig.email !== "" && tapoConfig.password !== "";

    readonly property var theme: Themes.active

    property bool lightOn: true
    property color lightColor: "#ff9f43"
    property int brightness: 75
    readonly property var tapoConfig: Config.config.bar.light.tapo
    readonly property string scriptPath: Qt.resolvedUrl("handler.py").toString().replace("file://", "")
    property bool commandInFlight: false
    property string pendingCommand: ""

    function toggleLight() {
        runCommand([lightOn ? "on" : "off"]);
    }

    function changeLightColor(color) {
        runCommand([
            "color",
            Math.round(color.r * 255).toString(),
            Math.round(color.g * 255).toString(),
            Math.round(color.b * 255).toString()
        ]);
    }

    function changeLightBrightness(value) {
        runCommand(["brightness", Math.round(value).toString()]);
    }

    function runCommand(args) {
        if (commandInFlight) {
            return;
        }

        commandInFlight = true;
        pendingCommand = args[0];
        tapoProcess.command = [tapoConfig.python, scriptPath, tapoConfig.ip, tapoConfig.email, tapoConfig.password, ...args];
        tapoProcess.running = true;
    }

    function loadDeviceInfo() {
        runCommand(["info"]);
    }

    function parsePythonValue(text) {
        return text.replace(/\bTrue\b/g, "true").replace(/\bFalse\b/g, "false").replace(/\bNone\b/g, "null").replace(/'/g, "\"");
    }

    function applyDeviceInfo(rawText) {
        try {
            const info = JSON.parse(parsePythonValue(rawText));

            lightOn = Boolean(info.device_on);
            brightness = Number(info.brightness || 0);

            const hue = Number(info.hue || 0) / 360;
            const saturation = Number(info.saturation || 0) / 100;
            lightColor = Qt.hsva(hue, saturation, 1, 1);
        } catch (e) {
            console.error(`Failed to parse tapo info: ${e}`);
        }
    }

    Component.onCompleted: {
        loadDeviceInfo();
    }

    contentItem: WrapperRectangle {
        width: 260
        color: theme.backgroundColor2
        radius: theme.borderRadius
        margin: theme.margin + 2

        ColumnLayout {
            width: parent.width
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    StyledText {
                        text: "Tapo L900"
                        font.pixelSize: 15
                    }

                    StyledText {
                        text: root.lightOn ? "On" : "Off"
                        color: root.lightOn ? root.lightColor : theme.textColor2
                        font.pixelSize: 12
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    id: toggleTrack
                    Layout.alignment: Qt.AlignVCenter
                    width: 48
                    height: 26
                    radius: height / 2
                    color: root.lightOn ? root.lightColor : theme.opacity(theme.textColor2, 0.25)

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        y: 3
                        x: root.lightOn ? parent.width - width - 3 : 3
                        color: "#ffffff"

                        Behavior on x {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.lightOn = !root.lightOn;
                            root.toggleLight();
                        }
                    }
                }
            }

            LightColorWheel {
                id: colorWheel
                Layout.alignment: Qt.AlignHCenter
                selectedColor: root.lightColor

                onColorPicked: color => {
                    root.lightColor = color;
                    root.changeLightColor(color);
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Brightness"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: `${root.brightness}%`
                        color: theme.textColor2
                    }
                }

                Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: root.brightness
                    enabled: !root.commandInFlight

                    onMoved: {
                        root.brightness = Math.round(value);
                        root.changeLightBrightness(root.brightness);
                    }

                    background: Rectangle {
                        x: brightnessSlider.leftPadding
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: brightnessSlider.availableWidth
                        height: implicitHeight
                        radius: height / 2
                        color: theme.opacity(theme.textColor2, 0.2)

                        Rectangle {
                            width: brightnessSlider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: root.lightOn ? root.lightColor : theme.textColor2
                        }
                    }

                    handle: Rectangle {
                        x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: width / 2
                        color: "#ffffff"
                        border.width: 2
                        border.color: root.lightOn ? root.lightColor : theme.textColor2
                    }
                }
            }
        }
    }

    WrapperRectangle {
        color: theme.backgroundColor
        radius: theme.borderRadius
        margin: theme.margin

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: root.lightOn ? root.lightColor : theme.textColor2
        }
    }

    Process {
        id: tapoProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                if (output !== "") {
                    console.log(`tapo.py: ${output}`);
                    if (root.pendingCommand === "info") {
                        root.applyDeviceInfo(output);
                    }
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                if (output !== "") {
                    console.error(`tapo.py: ${output}`);
                }
            }
        }

        onExited: {
            root.commandInFlight = false;
            root.pendingCommand = "";
        }
    }
}
