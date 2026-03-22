import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.element
import qs.utils
import qs.config
import qs.services.sound

RowLayout {
    StyledText {
        text: `${MprisUtil.shortTitle} - ${MprisUtil.shortArtist}`
    }
}
