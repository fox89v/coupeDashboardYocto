import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true

    Item {
        id: gauge
        width: 320
        height: 320
        anchors.centerIn: parent

        property real value: 0
        Behavior on value {
            NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
        }
        Rectangle {
            anchors.fill: parent
            color: "black"
            radius: width/2
        }
        Canvas {
            id: dial
            anchors.fill: parent
            anchors.margins: 8
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var cx = width/2
                var cy = height/2
                var r  = width/2

                // ghiera nera
                ctx.fillStyle = "#020202"
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI*2)
                ctx.fill()

                // quadrante verde scuro retroilluminato
                ctx.fillStyle = "#131f16"
                ctx.beginPath()
                ctx.arc(cx, cy, r - 6, 0, Math.PI*2)
                ctx.fill()

                // alone luminoso
                ctx.strokeStyle = "rgba(180,255,180,0.25)"
                ctx.lineWidth = 18
                ctx.beginPath()
                ctx.arc(cx, cy, r - 24, -2.1, 2.1)
                ctx.stroke()

                // tacche bianche, ultime in rosso
                for (var i = 0; i <= 24; ++i) {
                    var deg = -120 + i*10
                    var a   = deg * Math.PI / 180
                    var inner = r - 10
                    var outer = r - (i % 2 === 0 ? 26 : 20)

                    var isRed = deg > 80   // zona rossa a destra
                    ctx.strokeStyle = isRed ? "#ff5050" : "#f7f7f7"
                    ctx.lineWidth   = (i % 2 === 0) ? 3 : 1.5

                    ctx.beginPath()
                    ctx.moveTo(cx + Math.cos(a)*inner,
                               cy + Math.sin(a)*inner)
                    ctx.lineTo(cx + Math.cos(a)*outer,
                               cy + Math.sin(a)*outer)
                    ctx.stroke()
                }

                // pochissimi numeri tipo FIAT (0, 4, 8)
                ctx.fillStyle = "#f7f7f7"
                ctx.font = "bold 14px"

                function labelAt(text, deg, radius) {
                    var a = deg * Math.PI / 180
                    var x = cx + Math.cos(a)*radius
                    var y = cy + Math.sin(a)*radius + 5
                    ctx.fillText(text, x - 6, y)
                }

                labelAt("0",  -115, r - 42)
                labelAt("4",    0,  r - 42)
                labelAt("8",  115, r - 42)
            }
        }

        Rectangle {
                id: needle
                width: 96
                height: 3
                radius: 1.5
                color: "#249144ff"
                antialiasing: true

                // il perno sta al centro del gauge
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.horizontalCenter

                transform: Rotation {
                    origin.x: 0                    // ruota intorno al perno
                    origin.y: needle.height / 2
                    angle: -120 + gauge.value * 240
                }
            }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            anchors.centerIn: parent
            color: "#101010"
            border.color: "#666"
            border.width: 2
        }


    }
}
