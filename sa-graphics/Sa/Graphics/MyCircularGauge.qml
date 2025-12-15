import QtQuick

Item {
    id: gauge
    width: 240
    height: 240

    property var measure
    property real startAngle: -120
    property real endAngle: 120
    property Component needleComponent: defaultNeedle

    readonly property real normalizedValue: measure ? Math.max(0, Math.min(1, measure.normalized)) : 0
    readonly property real needleAngle: startAngle + normalizedValue * (endAngle - startAngle)

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "#0b0b0b"
        border.color: "#2f2f2f"
        border.width: 2
    }

    Canvas {
        id: dial
        anchors.fill: parent
        anchors.margins: 10
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = width / 2
            var cy = height / 2
            var r = width / 2

            ctx.strokeStyle = "#4caf50"
            ctx.lineWidth = 8
            ctx.beginPath()
            ctx.arc(cx, cy, r - 20, startAngle * Math.PI / 180, endAngle * Math.PI / 180)
            ctx.stroke()
        }
    }

    Loader {
        id: needleLoader
        anchors.centerIn: parent
        sourceComponent: needleComponent

        onLoaded: {
            if (item) {
                item.rotation = gauge.needleAngle
            }
        }
    }

    Binding {
        when: needleLoader.item !== null
        target: needleLoader.item
        property: "rotation"
        value: gauge.needleAngle
    }

    Component {
        id: defaultNeedle
        Rectangle {
            id: needle
            width: gauge.width * 0.42
            height: 4
            radius: 2
            color: "#e53935"
            antialiasing: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.horizontalCenter
            transformOrigin: Item.Left
        }
    }

    Rectangle {
        width: 16
        height: 16
        radius: 8
        anchors.centerIn: parent
        color: "#1a1a1a"
        border.color: "#3f3f3f"
    }
}
