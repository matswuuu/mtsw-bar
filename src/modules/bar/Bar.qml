import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.element
import qs.utils
import qs.theme
import qs.widget

PanelWindow {
    id: root
    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        left: 10
        right: 10
        top: 6
    }
    implicitHeight: 32

    readonly property var theme: Themes.active

    RowLayout {
        id: leftLayout
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        ResourceBlock {

        }
    }

    RowLayout {
        anchors {
            centerIn: parent
        }

        ClockWidget {
            id: clock
        }
    }

    RowLayout {
        id: rightLayout
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        SoundWidget {

        }

        System {

        }

        Tray {

        }
    }
}
