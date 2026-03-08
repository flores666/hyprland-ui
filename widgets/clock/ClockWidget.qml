import QtQuick
import Quickshell.Io
import "../../globals"

Rectangle {
	width: parent.width
	height: parent.height

	Rectangle {
		anchors.fill: parent
		color: Env.colors.primary

		Text {
			id: time
			color: Env.colors.text
			text: ClockManager.currentTime.substring(0, 6)
			font.pixelSize: 18
			anchors.right: filler.left
			anchors.verticalCenter: parent.verticalCenter
		}

		Rectangle {
			id: filler
			width: 6
			height: parent.height
			color: Env.colors.primary

			Rectangle {
				height: 3
				width: 3
				anchors.centerIn: parent
				color: Env.colors.text
				radius: 180
			}
		}

		Text {
			id: day
			color: Env.colors.text
			text: ClockManager.currentTime.substring(6)
			font.pixelSize: 13
			anchors.left: filler.right
			anchors.verticalCenter: parent.verticalCenter
			anchors.leftMargin: 3
		}
	}
}
