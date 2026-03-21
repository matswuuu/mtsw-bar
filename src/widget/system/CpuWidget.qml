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
    title: "CPU"   
    usageText: CpuUsage.cpuUsage + usageSymbol
    tempText: CpuUsage.cpuTemp + tempSymbol
    tempColor: CpuUsage.tempColor
    diagrams: [
        {
            "title": "CPU Usage (%)",
            "stepX": 10,
            "maxX": CpuUsage.maxHistory,
            "maxY": CpuUsage.maxUsage,
            "history": CpuUsage.usageHistory
        },
        {
            "title": "CPU Temperature (°C)",
            "stepX": 10,
            "maxX": CpuUsage.maxHistory,
            "maxY": CpuUsage.maxTemp,
            "history": CpuUsage.tempHistory
        },
        {
            "title": "CPU Frequency (MHz)",
            "stepX": 10,
            "minY": CpuUsage.minFreq,
            "maxX": CpuUsage.maxHistory,
            "maxY": CpuUsage.maxFreq,
            "history": CpuUsage.freqHistory
        }
    ]
}
