import QtQuick
import Quickshell.Io
import "../../globals"
import Quickshell.Widgets

Rectangle {
	width: parent.width * 0.1
	height: parent.height
	color: Env.colors.primary

	Row {
		spacing: 4
		anchors.centerIn: parent

		IconImage {
			id: icon
			source: Qt.resolvedUrl("icons/cpu.svg")
			width: 18
			height: 18
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
			id: clock
			color: Env.colors.text
			text: CpuLoad.currentLoad
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
