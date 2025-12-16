import QtQuick
import QtQuick.Controls
import Sa.Graphics 1.0

ApplicationWindow {
    visible: true
    width: 400
    height: 400
    color: "#0f1116"

    property real gaugeValue: 0.0

    Behavior on gaugeValue {
        NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
    }

    SequentialAnimation on gaugeValue {
        loops: Animation.Infinite
        NumberAnimation { from: 0.0; to: 1.0; duration: 1200; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 400 }
        NumberAnimation { from: 1.0; to: 0.15; duration: 900; easing.type: Easing.InOutQuad }
        PauseAnimation { duration: 500 }
    }

    MyCircularGauge {
        id: gauge
        anchors.centerIn: parent
        width: 320
        height: 320
        measure: QtObject {
            property real normalized: gaugeValue
        }
    }
}
