import qs.theme
import QtQml.Models
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.widget
import qs.config

WrapperRectangle {
    readonly property var theme: Themes.active

    property
        list < SystemTrayItem > items
    :
    {
        var items = [...SystemTray.items.values];
        return items.sort((a, b) => {
            const iconOrder = Config.config.bar.tray.iconOrder;
            const aname = a.id.toLowerCase();
            const bname = b.id.toLowerCase();
            const ai = iconOrder.findIndex(k => aname.includes(k));
            const bi = iconOrder.findIndex(k => bname.includes(k));

            if (ai !== -1 && bi !== -1) return ai - bi;
            if (ai !== -1) return -1;
            if (bi !== -1) return 1;

            return aname.localeCompare(bname);
        });
    }

    id: root
    color: theme.backgroundColor
    radius: theme.borderRadius
    margin: theme.margin

    RowLayout {
        spacing: 4

        Repeater {
            model: root.items
            delegate: TrayItem {
                required property SystemTrayItem modelData
                item: modelData
            }
        }
    }
}
