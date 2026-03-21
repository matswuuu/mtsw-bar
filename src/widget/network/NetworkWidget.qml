import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.element
import qs.theme
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
                    `IP: ${IpInfo.ip}`,
                    `Country: ${IpInfo.country}, ${IpInfo.city} (${IpInfo.countryCode})`,
                    `Timezone: ${IpInfo.timezone}`,
                    `ISP: ${IpInfo.isp}`
                ].join("\n")
            }
        }
    }

    StyledText {
        text: Network.connectionSymbol
    }
}
