import QtQuick
import qs.theme

Item {
    id: root

    readonly property var theme: Themes.active

    property color selectedColor: "#ffffff"
    property real hue: 0
    property real saturation: 0
    property real markerX: width / 2
    property real markerY: height / 2

    signal colorPicked(color color)

    implicitWidth: 180
    implicitHeight: 180

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value));
    }

    function updateFromPoint(x, y) {
        const centerX = width / 2;
        const centerY = height / 2;
        const dx = x - centerX;
        const dy = y - centerY;
        const radius = Math.min(width, height) / 2;
        const distance = Math.sqrt(dx * dx + dy * dy);

        if (distance > radius) {
            const scale = radius / distance;
            x = centerX + dx * scale;
            y = centerY + dy * scale;
        }

        const normalizedDx = x - centerX;
        const normalizedDy = y - centerY;
        const normalizedDistance = Math.sqrt(normalizedDx * normalizedDx + normalizedDy * normalizedDy);

        markerX = x;
        markerY = y;
        hue = (Math.atan2(normalizedDy, normalizedDx) / (Math.PI * 2) + 1) % 1;
        saturation = clamp(normalizedDistance / radius, 0, 1);
        selectedColor = Qt.hsva(hue, saturation, 1, 1);
        colorPicked(selectedColor);
    }

    function syncMarkerToSelectedColor() {
        const radius = Math.min(width, height) / 2;
        const centerX = width / 2;
        const centerY = height / 2;
        const selectedHue = Number.isNaN(selectedColor.hsvHue) ? 0 : selectedColor.hsvHue;
        const selectedSaturation = selectedColor.hsvSaturation;
        const angle = selectedHue * Math.PI * 2;
        const distance = selectedSaturation * radius;

        hue = selectedHue;
        saturation = selectedSaturation;
        markerX = centerX + Math.cos(angle) * distance;
        markerY = centerY + Math.sin(angle) * distance;
    }

    Component.onCompleted: {
        syncMarkerToSelectedColor();
        wheel.requestPaint();
    }
    onSelectedColorChanged: {
        syncMarkerToSelectedColor();
    }
    onWidthChanged: {
        syncMarkerToSelectedColor();
        wheel.requestPaint();
    }
    onHeightChanged: {
        syncMarkerToSelectedColor();
        wheel.requestPaint();
    }

    Canvas {
        id: wheel
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Cooperative

        onPaint: {
            const ctx = getContext("2d");
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = Math.min(width, height) / 2;
            const whiteGradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius);

            ctx.clearRect(0, 0, width, height);
            ctx.save();
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2);
            ctx.clip();

            for (let i = 0; i < 360; i++) {
                const startAngle = (i - 1) * Math.PI / 180;
                const endAngle = (i + 1) * Math.PI / 180;

                ctx.beginPath();
                ctx.moveTo(centerX, centerY);
                ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                ctx.closePath();
                ctx.fillStyle = Qt.hsva(i / 360, 1, 1, 1);
                ctx.fill();
            }

            whiteGradient.addColorStop(0, "rgba(255, 255, 255, 1)");
            whiteGradient.addColorStop(1, "rgba(255, 255, 255, 0)");
            ctx.fillStyle = whiteGradient;
            ctx.fillRect(0, 0, width, height);
            ctx.restore();
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: theme.opacity(theme.textColor, 0.18)
    }

    Rectangle {
        width: 18
        height: 18
        radius: 9
        x: root.markerX - width / 2
        y: root.markerY - height / 2
        color: root.selectedColor
        border.width: 2
        border.color: "#ffffff"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onPressed: mouse => {
            root.updateFromPoint(mouse.x, mouse.y);
        }
        onPositionChanged: mouse => {
            if (pressed) {
                root.updateFromPoint(mouse.x, mouse.y);
            }
        }
    }
}
