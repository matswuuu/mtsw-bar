import QtQml.Models
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.widget
import qs.element
import qs.theme
import qs.utils

WrapperRectangle {
    readonly property var theme: Themes.active

    id: root
    color: theme.backgroundColor
    radius: theme.borderRadius
    margin: theme.margin

    RowLayout {
        spacing: 4

        LanguageWidget {

        }

        BatteryWidget {

        }

        NetworkWidget {

        }

        LightWidget {

        }

        BluetoothWidget {

        }
    }
}
