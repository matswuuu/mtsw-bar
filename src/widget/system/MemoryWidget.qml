import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Widgets
import qs.widget
import qs.element
import qs.utils
import qs.services.system

ResourceWidget {
    usageText: Formatter.formatKBtoGB(MemoryUsage.memoryUsed)
    diagrams: [
        {
            "title": "Memory Usage (GB)",
            "stepX": 10,
            "maxX": MemoryUsage.maxHistory,
            "maxY": MemoryUsage.memoryTotal,
            "history": MemoryUsage.usageHistory,
            "yFormatter": (y) => Formatter.formatKBtoGB(y)
        },
        // {
        //     "title": "Memory Usage (G)",
        //     "stepX": 10,
        //     "maxX": MemoryUsage.maxHistory,
        //     "maxY": MemoryUsage.maxUsage,
        //     "history": MemoryUsage.usageHistory
        // }
    ]
}
