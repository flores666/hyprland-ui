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

				property bool isActive: Hyprland.focusedWorkspace.id == modelData

				Rectangle {
					property int circleRadius: isActive ? root.height * 0.6 : root.height * 0.24
					width: circleRadius
					height: circleRadius
					radius: 180
					color: isActive ? Env.colors.text : Env.colors.gray
					anchors.centerIn: parent
				}

				MouseArea {
					anchors.fill: parent
					onClicked: Hyprland.dispatch("workspace " + modelData)
					cursorShape: Qt.PointingHandCursor
				}
			}
		}
	}

}

