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
    visible: GpuUsage.isPresented
    title: I18n.t("system.gpu")
    usageText: GpuUsage.gpuUsage + usageSymbol
    tempText: GpuUsage.gpuTemp + tempSymbol
    tempColor: GpuUsage.tempColor
    diagrams: [
        {
            "title": I18n.t("system.gpuUsage"),
            "stepX": 10,
            "maxX": GpuUsage.maxHistory,
            "maxY": GpuUsage.maxUsage,
            "history": GpuUsage.usageHistory
        },
        {
            "title": I18n.t("system.gpuTemp"),
            "stepX": 10,
            "maxX": GpuUsage.maxHistory,
            "maxY": GpuUsage.maxTemp,
            "history": GpuUsage.tempHistory
        },
        {
            "title": I18n.t("system.gpuFreq"),
            "stepX": 10,
            "minY": GpuUsage.minGpuFreq,
            "maxX": GpuUsage.maxHistory,
            "maxY": GpuUsage.maxGpuFreq,
            "history": GpuUsage.freqHistory
        }
    ]
}
