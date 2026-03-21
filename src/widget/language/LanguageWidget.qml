import QtQml.Models
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.element
import qs.theme
import qs.i18n
import qs.utils

StyledPopup {
    readonly property var theme: Themes.active

    contentItem: WrapperRectangle {
        color: theme.backgroundColor2
        radius: theme.borderRadius
        margin: theme.margin + 4

        ColumnLayout {
            spacing: 8

            Repeater {
                model: LanguageAdapter.layouts
                delegate: StyledText {
                    text: I18n.t(
                        "language.item",
                        modelData,
                        LanguageAdapter.fullTranslations[modelData]
                    )
                    color: modelData === LanguageAdapter.activeLayout ? theme.textColor2 : theme.textColor
                }
            }
        }
    }

    onClicked: {
        LanguageAdapter.nextLanguage();
    }

    RowLayout {
        StyledText {
            text: LanguageAdapter.translatedLayout
        }
    }
}
