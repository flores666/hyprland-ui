import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import "../../globals"
import Quickshell.Io

Rectangle {
	id: brightnessWidget
	height: parent.height
	width: parent.width * 0.1
	color: Env.colors.primary

	IconImage {
		id: image
		width: 18
		height: 18
		anchors.centerIn: parent
	}

	// локальное состояние яркости (0..1)
	property real uiBrightness: 0.5
	property int maxBrightness: 100

	// процессы для яркости
	Process {
		id: brightMaxProcess
		command: ["brightnessctl", "max"]
		running: false
		stdout: StdioCollector {
			onStreamFinished: {
				let output = this.text.trim();
				if (output !== "") {
					brightnessWidget.maxBrightness = parseInt(output);
					brightGetProcess.running = true;
				}
				brightMaxProcess.running = false;
			}
		}
	}

	Process {
		id: brightGetProcess
		command: ["brightnessctl", "get"]
		running: false
		stdout: StdioCollector {
			onStreamFinished: {
				let output = this.text.trim();
				if (output !== "" && brightnessWidget.maxBrightness > 0) {
					let value = parseInt(output);
					brightnessWidget.uiBrightness = Math.max(0, Math.min(1, value / brightnessWidget.maxBrightness));
					brightnessWidget.resolveImageSource();
				}
				brightGetProcess.running = false;
			}
		}
	}

	Process {
		id: brightPlusProcess
		command: ["brightnessctl", "set", "7%+"]
		running: false
		stdout: StdioCollector {
			onStreamFinished: {
				brightGetProcess.running = true;
				brightPlusProcess.running = false;
			}
		}
	}

	Process {
		id: brightMinusProcess
		command: ["brightnessctl", "set", "7%-"]
		running: false
		stdout: StdioCollector {
			onStreamFinished: {
				brightGetProcess.running = true;
				brightMinusProcess.running = false;
			}
		}
	}

	Component.onCompleted: brightMaxProcess.running = true;

	function resolveImageSource() {
		let lowSource = Qt.resolvedUrl("icons/brightness_low.svg");
		let midSource = Qt.resolvedUrl("icons/brightness_medium.svg");
		let highSource = Qt.resolvedUrl("icons/brightness_high.svg");

		if (uiBrightness === 0) image.source = lowSource;
		else if (uiBrightness < 0.5) image.source = midSource;
		else image.source = highSource;
	}

	// ---------- вертикальный скроллбар ----------
	Rectangle {
		id: sliderContainer
		width: parent.width
		height: parent.height
		color: "transparent"
		anchors.centerIn: parent

		Slider {
			id: slider
			orientation: Qt.Vertical
			from: 0
			to: 1
			stepSize: 0.01
			value: uiBrightness
			anchors.centerIn: parent
			height: parent.height * 0.8

			handle: Rectangle {
				width: 24
				height: 12
				radius: 8
				color: Env.colors.secondary
			}

			background: Rectangle {
				width: 4
				radius: 2
				color: Env.colors.primary
			}

			onValueChanged: {
				brightnessWidget.uiBrightness = slider.value;
				resolveImageSource();
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onWheel: event => {
					let up = event.angleDelta.y > 0;
					if (up) brightPlusProcess.running = true;
					else brightMinusProcess.running = true;

					// мгновенно обновляем локально для UI
					if (up) uiBrightness = Math.min(1, uiBrightness + 0.05);
					else uiBrightness = Math.max(0, uiBrightness - 0.05);
					slider.value = uiBrightness;
					resolveImageSource();
				}
			}
		}
	}
}

