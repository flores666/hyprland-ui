import QtQuick
import Quickshell.Io
import "../../globals"
import Quickshell.Widgets

Rectangle {
    width: parent.width
    height: parent.height
    color: Env.colors.primary
    radius: 180

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            screenshotProcess.running = true;
        }
    }

    IconImage {
        id: icon
        source: Qt.resolvedUrl("icons/screen.svg")
        width: 14
        height: 14
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Process {
        id: screenshotProcess
        command: ["sh", "-c", "hyprshot -m window"]
        running: false
    }
}
