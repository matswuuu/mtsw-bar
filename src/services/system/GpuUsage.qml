pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton
{
    property int maxHistory: 60

    property int maxUsage: 100
    property int gpuUsage: 0

    property int maxTemp: 100
    property int gpuTemp: 0
    property color tempColor

    property int gpuFreq: 0
    property int minGpuFreq: 0
    property int maxGpuFreq: 1

    property bool isPresented: nvidia || amd
    property bool nvidia
    property bool amd
    property string cardPath

    property list < int > usageHistory
    :
    []
    property list < int > tempHistory
    :
    []
    property list < int > freqHistory
    :
    []

    function pushToHistory(array, value) {
        if (array.length >= maxHistory)
            array.shift()
        array.push(value)
    }

    // --- NVIDIA ---

    Process {
        id: checkProcess
        command: ["which", "nvidia-smi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                nvidia = this.text.trim().length > 0
            }
        }
    }

    Process {
        id: gpuUsageProcess
        command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                gpuUsage = parseInt(this.text)
                pushToHistory(usageHistory, gpuUsage)
            }
        }
    }

    Process {
        id: gpuTempProcess
        command: ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                gpuTemp = parseInt(this.text)
                pushToHistory(tempHistory, gpuTemp)

                const percent = gpuTemp / maxTemp
                tempColor = Qt.rgba(
                    (128 + 127 * percent) / 255,
                    (128 + 127 * (1 - percent)) / 255,
                    0,
                    1
                )
            }
        }
    }

    // --- AMD ---

    Process {
        id: findAmdProcess
        command: ["bash", "-c", "for d in /sys/class/drm/card*/device; do if [ -f \"$d/vendor\" ]; then v=$(cat \"$d/vendor\"); if [ \"$v\" = \"0x1002\" ]; then echo \"$d\"; break; fi; fi; done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const path = this.text.trim()
                if (path.length > 0) {
                    cardPath = path
                    amd = true
                }
            }
        }
    }

    Process {
        id: amdUsageProcess
        command: ["bash", "-c", "cat " + cardPath + "/gpu_busy_percent || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                gpuUsage = parseInt(this.text) || 0
                pushToHistory(usageHistory, gpuUsage)
            }
        }
    }

    Process {
        id: amdTempProcess
        command: ["bash", "-c", "cat $(ls " + cardPath + "/hwmon/hwmon*/temp1_input 2>/dev/null | head -1) 2>/dev/null || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                const tempRaw = parseInt(this.text) || 0
                gpuTemp = Math.floor(tempRaw / 1000)
                pushToHistory(tempHistory, gpuTemp)

                const percent = gpuTemp / maxTemp
                tempColor = Qt.rgba(
                    (128 + 127 * percent) / 255,
                    (128 + 127 * (1 - percent)) / 255,
                    0,
                    1
                )
            }
        }
    }

    Process {
        id: amdFreqProcess
        command: ["bash", "-c", "grep '*' " + cardPath + "/pp_dpm_sclk 2>/dev/null | grep -oP '\\d+' || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: {
                gpuFreq = parseInt(this.text) || 0
                pushToHistory(freqHistory, gpuFreq)
            }
        }
    }

    FileView {
        id: fileAmdMaxFreq
        path: cardPath.length > 0 ? cardPath + "/pp_dpm_sclk" : ""
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (nvidia) {
                gpuUsageProcess.running = true
                gpuTempProcess.running = true
            }
            if (amd) {
                amdUsageProcess.running = true
                amdTempProcess.running = true
                amdFreqProcess.running = true

                fileAmdMaxFreq.reload()
                const lines = fileAmdMaxFreq.text().split("\n")
                let maxVal = 0
                let minVal = Infinity
                for (let line of lines) {
                    const match = line.match(/(\d+)\s*MHz/)
                    if (match) {
                        const val = parseInt(match[1])
                        if (val > maxVal) maxVal = val
                        if (val < minVal) minVal = val
                    }
                }
                if (maxVal > 0) {
                    maxGpuFreq = maxVal
                    minGpuFreq = minVal === Infinity ? 0 : minVal
                }
            }
        }
    }
}
