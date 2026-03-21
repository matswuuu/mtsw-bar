import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Widgets
import qs.widget
import qs.element
import qs.i18n
import qs.utils
import qs.services.system

ResourceWidget {
    title: I18n.t("system.cpu")   
    usageText: CpuUsage.cpuUsage + usageSymbol
    tempText: CpuUsage.cpuTemp + tempSymbol
    tempColor: CpuUsage.tempColor
    diagrams: [
        {
            "title": I18n.t("system.cpuUsage"),
            "stepX": 10,
            "maxX": CpuUsage.maxHistory,
            "maxY": CpuUsage.maxUsage,
            "history": CpuUsage.usageHistory
        },
        {
            "title": I18n.t("system.cpuTemp"),
            "stepX": 10,
            "maxX": CpuUsage.maxHistory,
            "maxY": CpuUsage.maxTemp,
            "history": CpuUsage.tempHistory
        },
        {
            "title": I18n.t("system.cpuFreq"),
            "stepX": 10,
            "minY": CpuUsage.minFreq,
            "maxX": CpuUsage.maxHistory,
            "maxY": CpuUsage.maxFreq,
            "history": CpuUsage.freqHistory
        }
    ]
}
