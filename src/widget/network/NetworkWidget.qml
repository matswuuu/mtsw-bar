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
                    I18n.t(
                        "network.country",
                        IpInfo.country,
                        IpInfo.city,
                        IpInfo.countryCode
                    ),
                    I18n.t("network.timezone", IpInfo.timezone),
                    I18n.t("network.isp", IpInfo.isp)
                ].join("\n")
            }
        }
    }

    StyledText {
        text: Network.connectionSymbol
    }
}
