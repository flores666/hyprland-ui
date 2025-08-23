import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../../globals"
import Quickshell.Hyprland

Rectangle {
    id: root
    width: parent.width * 0.5
    height: parent.height
    color: Env.colors.primary

    Row {
        id: workspacesRow
        height: parent.height

        property var allWorkspaces: Array(9).fill(0).map((_, i) => i + 1)

        Repeater {
            model: workspacesRow.allWorkspaces

            delegate: Rectangle {
                width: root.height
                height: root.height
                color: "transparent"

				property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id == modelData
				property bool showTrail: false

				Rectangle {
					anchors.centerIn: parent
					width: root.height * 0.6
					height: root.height * 0.6
					radius: 180
					color: isActive ? Env.colors.text : "transparent"
					visible: showTrail
					opacity: 0.5
				}

				// Основной кружок
				Rectangle {
					property int circleRadius: isActive ? root.height * 0.6 : root.height * 0.24
					width: circleRadius
					height: circleRadius
					radius: 180
					color: isActive ? Env.colors.text : Env.colors.gray
					anchors.centerIn: parent

					Behavior on width { NumberAnimation { duration: 200 } }
					Behavior on height { NumberAnimation { duration: 200 } }
					Behavior on color { ColorAnimation { duration: 200 } }
				}

				MouseArea {
					anchors.fill: parent
					onClicked: Hyprland.dispatch("workspace " + modelData)
					cursorShape: Qt.PointingHandCursor
				}

				Connections {
					target: Hyprland.focusedWorkspace
					function onIdChanged(newId) {
						if (isActive) {
							showTrail = true
							trailTimer.restart()
						}
					}
				}

				Timer {
					id: trailTimer
					interval: 200
					running: false
					repeat: false
					onTriggered: showTrail = false
				}
			}
		}
	}
}

