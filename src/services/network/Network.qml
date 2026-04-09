pragma Singleton

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import qs.utils
import qs.config

Singleton {
    property string offSymbol: "󰖪"
    property string lanSymbol: ""
    property var wifiSymbols: ({
        0: "󰤯",
        25: "󰤟",
        50: "󰤢",
        75: "󰤥",
        90: "󰤨"
    })

    property int networkStrength
    property int type: NetworkType.NONE
    property string connectionSymbol: getFormattedConnection()
    property var hostStates: {}

    function getFormattedConnection(): string {
        switch (type) {
            case 0:
                return offSymbol
            case 1:
                return lanSymbol
            case 2:
                return Collection.floorValue(wifiSymbols, networkStrength)
        }
    }

    function updateHostState(host, state) {
        let newStates = hostStates || {}; 
        newStates[host.host] = {
            host: host,
            state: state
        }
        hostStates = newStates;
        for (const h in hostStates) {
            print(`${h}: ${hostStates[h].state == NetworkState.CONNECTED ? "CONNECTED" : "TIMEOUT"}`)
        }
    }

    Process {
        id: typeProcess
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE device | awk -F: '$2 == \"connected\" {print $1}'"]
        stdout: SplitParser {
            onRead: data => {
                switch (data.trim()) {
                    case "wifi":
                        type = NetworkType.WIFI
                        break
                    case "ethernet":
                        type = NetworkType.ETHERNET
                        break
                    default:
                        type = NetworkType.NONE
                }
            }
        }
    }

    Process {
        id: strengthProcess
        running: true
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => {
                networkStrength = parseInt(data);
            }
        }
    }

    Component {
        id: hostCheckComponent

        Process {
            property var host
            property string pingCommand: host.pingCommand.replace("$HOST", host.host);

            command: ["sh", "-c", pingCommand]
            running: true
            onExited: (code, status) => {
                const state = code == 0
                    ? NetworkState.CONNECTED
                    : NetworkState.TIMEOUT;
                updateHostState(host, state)
                destroy()
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            typeProcess.running = true
            strengthProcess.running = true
        }
    }

    Timer {
        // interval: 60 * 1000
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const hosts = Config.config.bar.network.hosts;
            for (const host of hosts) {
                const obj = hostCheckComponent.createObject(null, {
                    host: host
                })
            }
        }
    }
}
