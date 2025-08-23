import Quickshell
import QtQuick
import "widgets/clock"
import "widgets/cpuload"
import "widgets/workspaces"
import "widgets/brightness"
import "widgets/volume"
import "globals"

Variants {
	model: Quickshell.screens;

	delegate: Component {
		PanelWindow {
			property var modelData
			screen: modelData

			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: Env.sizes.barHeight;

			Rectangle {
				id: left
				color: Env.colors.primary
				anchors { 
					left: parent.left
					top: parent.top
				}

				width: Screen.width * Env.sizes.barWidthCoef
				height: parent.height

				BrightnessWidget {
					id: brightnessWidget
					width: 20
					onBrightnessChange: brightnessScrollBar.handleBrightnessChange(brightnessWidget.uiBrightness);
				}

				BrightnessScrollBar {
					id: brightnessScrollBar
				}
			}

			Rectangle {
				id: center
				color: Env.colors.primary
				height: parent.height
				anchors { 
					right: right.left
					left: left.right
					top: parent.top
				}

				Rectangle {
					anchors.centerIn: center 
					height: parent.height

					CpuLoadWidget {
						id: cpuLoadWidget
						width: 54
						height: parent.height
						anchors.verticalCenter: parent.verticalCenter
						anchors.right: workspaces.left
					}

					WorkspacesWidget {
						id: workspaces
						width: 255
						height: parent.height
						anchors.horizontalCenter: parent.horizontalCenter
					}

					ClockWidget {
						id: clockWidget
						width: 140
						height: parent.height
						anchors.verticalCenter: parent.verticalCenter
						anchors.left: workspaces.right
					}
				}
			}

			Rectangle {
				id: right
				color: Env.colors.primary
				anchors { 
					right: parent.right
					top: parent.top
				}

				width: Screen.width * Env.sizes.barWidthCoef
				height: parent.height

				VolumeWidget {
					width: 20
					anchors.right: right.right
				}
			}
		}
	}
}


