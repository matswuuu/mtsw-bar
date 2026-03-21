import QtQml.Models
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.element
import qs.theme
import qs.i18n
import qs.utils
import qs.services.battery

StyledPopup {
    readonly property var theme: Themes.active

    property var device: Battery.device
    property string timeToEmpty: I18n.t(
        "battery.timeToEmpty",
        Formatter.formatTime(device.timeToEmpty)
    )
    property string timeToFull: I18n.t(
        "battery.timeToFull",
        Formatter.formatTime(device.timeToFull)
    )
    property string energy: I18n.t(
        "battery.energy",
        device.energy.toFixed(0),
        device.energyCapacity.toFixed(0),
        device.changeRate.toFixed(0)
    )

    visible: Battery.present

    contentItem: WrapperRectangle {
        color: theme.backgroundColor2
        radius: theme.borderRadius
        margin: theme.margin + 4

        RowLayout {
            StyledText {
                text: [
                    ...(device.timeToEmpty > 0 ? [timeToEmpty] : []),
                    ...(device.timeToFull > 0 ? [timeToFull] : []),
                    energy
                ].join("\n")
            }
        }
    }

    StyledText {
        text: I18n.t("battery.percent", Battery.percentage)
    }
}
