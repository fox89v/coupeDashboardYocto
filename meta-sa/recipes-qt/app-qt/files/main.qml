import QtQuick
import QtQuick.Controls
import Sa.Graphics 1.0

ApplicationWindow {
    id: root
    width: 400
    height: 520
    visible: true
    color: "#111111"

    Column {
        anchors.centerIn: parent
        spacing: 24

        MyCircularGauge {
            id: speedGauge
            width: 320
            height: 320
            measure: DataHub.measures["speed"]
        }

        Slider {
            id: speedControl
            width: 320
            from: 0
            to: 260
            value: DataHub.measures["speed"].value
            onValueChanged: DataHub.measures["speed"].value = value
        }

        Text {
            text: qsTr("Speed: %1 km/h").arg(DataHub.measures["speed"].value.toFixed(0))
            color: "white"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
        }
    }
}
