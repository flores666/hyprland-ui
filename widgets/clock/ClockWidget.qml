import QtQuick
import Quickshell.Io
import "../../globals"

Rectangle {
	width: parent.width * 0.1
	height: parent.height
	color: Env.colors.primary

	Text {
		id: clock
		anchors.centerIn: parent
		color: Env.colors.text
		text: ClockManager.currentTime
	}
}
