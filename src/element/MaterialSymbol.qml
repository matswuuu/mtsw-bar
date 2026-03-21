import QtQuick
import Quickshell
import qs.theme

Text {
    readonly property var theme: Themes.active
    
    font {
        family: Icons.font.name
        pixelSize: 28
    }
    color: theme.textColor
}
