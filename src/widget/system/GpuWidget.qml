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
    visible: GpuUsage.isPresented
    title: "GPU"   
    usageText: GpuUsage.gpuUsage + usageSymbol
    tempText: GpuUsage.gpuTemp + tempSymbol
    tempColor: GpuUsage.tempColor
    diagrams: [
        {
            "title": "GPU Usage (%)",
            "stepX": 10,
            "maxX": GpuUsage.maxHistory,
            "maxY": CpuUsage.maxUsage,
            "history": CpuUsage.usageHistory
        },
        {
            "title": "GPU Temperature (°C)",
            "stepX": 10,
            "maxX": GpuUsage.maxHistory,
            "maxY": GpuUsage.maxTemp,
            "history": GpuUsage.tempHistory
        }
    ]
}
