import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.bar
import qs.element
import qs.config
import qs.widget.clipboard

ShellRoot {
    Variants {
        model: Quickshell.screens.filter(monitor => Config.config.monitors.includes(monitor.name))

        Scope {
            required property var modelData

            Bar {
                id: bar
                screen: modelData

                MouseArea {
                    id: wrapper
                    implicitWidth: 400
                    implicitHeight: 400

                    onClicked: {
                        const xhr = new XMLHttpRequest();

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState !== XMLHttpRequest.DONE) return;

                            if (xhr.status === 200) {
                                console.log(xhr.responseText);
                            } else {
                                console.error("Request failed, status:", xhr.status);
                            }
                        };

                        xhr.open("GET", "", true);
                        xhr.send();
                    }
                }
            }

            ScreenOverlay {
                screen: modelData
                margins {
                    top: bar.margins.top * 2 + bar.height
                }
            }
        }
    }

    ClipboardPopup {
        screen: Quickshell.screens[0]
    }
}
