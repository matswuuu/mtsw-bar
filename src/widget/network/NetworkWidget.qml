import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.element
import qs.theme
import qs.i18n
import qs.utils
import qs.services.network

StyledPopup {
    readonly property var theme: Themes.active

    contentItem: WrapperRectangle {
        color: theme.backgroundColor2
        radius: theme.borderRadius
        margin: theme.margin

        ColumnLayout {
            spacing: 4

            StyledText {
                text: [
                    I18n.t("network.ip", IpInfo.ip),
                    I18n.t("network.country",
                        IpInfo.country,
                        IpInfo.city,
                        IpInfo.countryCode
                    ),
                    I18n.t("network.timezone", IpInfo.timezone),
                    I18n.t("network.isp", IpInfo.isp)
                ].join("\n")
            }

            // Spacer
            Item {
                implicitHeight: 8
            }

            Repeater {
                model: Object.values(Network.hostStates)

                RowLayout {
                    spacing: 6

                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4

                        color: {
                            if (modelData.state === NetworkState.TIMEOUT) return theme.red
                            if (modelData.latency < 75) return theme.green
                            if (modelData.latency < 200) return theme.yellow
                            return theme.red
                        }

                        Layout.alignment: Qt.AlignVCenter
                    }

                    StyledText {
                        text: {
                            if (modelData.state === NetworkState.TIMEOUT) {
                                return `${modelData.host.host} (timeout)`
                            }
                            return `${modelData.host.host} ${modelData.latency}ms`
                        }
                    }
                }
            }
        }
    }

    StyledText {
        text: Network.connectionSymbol
    }
}
