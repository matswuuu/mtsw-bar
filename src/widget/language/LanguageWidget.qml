import QtQml.Models
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "./../element/"
import "./../theme/"
import "./../utils/"

StyledPopup {
    readonly property var theme: Themes.active

    contentItem: WrapperRectangle {
        color: theme.backgroundColor2
        radius: theme.borderRadius
        margin: theme.margin + 4

        ColumnLayout {
            spacing: 8

            Repeater {
                model: Hyprland.layouts
                delegate: StyledText {
                    text: `${modelData} - ${Hyprland.fullTranslations[modelData]}`
                    color: modelData === Hyprland.activeLayout ? theme.textColor2 : theme.textColor
                }
            }
        }
    }

    onClicked: {
        LanguageAdapter.nextLanguage();
    }

    RowLayout {
        StyledText {
            text: Hyprland.translatedLayout
        }
    }
}