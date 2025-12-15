import QtQuick 2.15

Item {
    id: root

    property var measure
    property real startAngle: -140
    property real endAngle: 140
    property Component needle: defaultNeedle

    readonly property real normalizedValue: measure && measure.normalized !== undefined
                                         ? Math.max(0, Math.min(1, measure.normalized))
                                         : 0
    readonly property real needleAngle: startAngle + normalizedValue * (endAngle - startAngle)

    implicitWidth: 200
    implicitHeight: 200

    Rectangle {
        id: dial
        anchors.fill: parent
        radius: width / 2
        color: "#1f242c"
        border.color: "#4c566a"
        border.width: 2
        antialiasing: true
    }

    Item {
        id: needleContainer
        anchors.fill: parent
        transformOrigin: Item.Center
        rotation: needleAngle

        Loader {
            id: needleLoader
            anchors.centerIn: parent
            sourceComponent: root.needle
        }
    }

    Rectangle {
        id: centerCap
        width: root.width * 0.08
        height: width
        radius: width / 2
        color: "#dfe2e7"
        border.color: "#4c566a"
        anchors.centerIn: parent
        antialiasing: true
    }

    Component {
        id: defaultNeedle
        Rectangle {
            width: root.width * 0.05
            height: root.height * 0.45
            radius: width / 2
            color: "#e95420"
            border.color: "#c4451b"
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            antialiasing: true
        }
    }
}
