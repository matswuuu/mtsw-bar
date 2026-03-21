import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.element
import qs.config

ShellRoot {

  Variants {
    model: Quickshell.screens.filter(monitor => Config.config.monitors.includes(monitor.name))

    Scope {
      required property var modelData

      Bar {
        id: bar
        screen: modelData
      }

      ScreenOverlay {
        screen: modelData
        margins {
          top: bar.margins.top * 2 + bar.height
        }
      }
    }   
  }
}
