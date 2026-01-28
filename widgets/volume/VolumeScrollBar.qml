import QtQuick.Controls
import Quickshell
import QtQuick
import Quickshell.Services.Pipewire
import "../../globals"

PanelWindow {
	id: root
	visible: false
	implicitHeight: 152
	implicitWidth: 40
	color: "transparent"

	anchors {
		right: true
		top: true
	}

	margins {
		top: 6
		right: 6
	}

	property bool ready: Pipewire.defaultAudioSink?.ready ?? false
	property PwNode sink: Pipewire.defaultAudioSink
	property real uiVolume: 0

	PwObjectTracker {
		objects: [sink]
	}

	Connections {
		target: sink ? sink.audio : null
		function onVolumeChanged() {
			root.visible = true;
			visibilityHandler.restart();
			if (!sink || !sink.audio) {
				uiVolume = 0;
				slider.value = uiVolume;
				return;
			}
			uiVolume = clampVolume(sink.audio.volume);
			slider.value = uiVolume;
		}
	}

	onSinkChanged: {
		if (!sink || !sink.audio) {
			uiVolume = 0;
			slider.value = uiVolume;
			return;
		}
		uiVolume = clampVolume(sink.audio.volume);
		slider.value = uiVolume;
	}

	function clampVolume(value) : real {
		if (value == null || isNaN(value)) {
			return 0;
		}
		return Math.max(0, Math.min(1, value));
	}

	Rectangle {
		color: Env.colors.primary
		height: parent.height
		width: parent.width
		radius: 20

		Slider {
			id: slider
			orientation: Qt.Vertical
			stepSize: 0.05
			from: 0
			to: 1
			z: 2
			value: uiVolume
			anchors.centerIn: parent
			height: 134
			width: 8
			handle: Rectangle {
				width: 30
				height: 11
				radius: 16
				border.color: Env.colors.primary
				border.width: 4
				color: Env.colors.secondary

				x: (slider.width - width) / 2
				y: slider.visualPosition * (slider.height - height)

				MouseArea {
					id: dragArea
					anchors.fill: parent
					drag.target: parent
					drag.axis: Drag.YAxis
					drag.minimumY: 0
					drag.maximumY: slider.height - parent.height

					onPressed: slider.pressed = true
					onReleased: slider.pressed = false

					onPositionChanged: event => {
						var y = parent.y
						// ограничиваем диапазон
						y = Math.max(0, Math.min(slider.height - parent.height, y))

						// вычисляем значение ползунка от 0 до 1 (сверху вниз)
						var value = y / (slider.height - parent.height)
						slider.value = 1 - value
						slider.moved()
					}
				}
			}

			background: Rectangle {
				color: Env.colors.text
				height: parent.height
				width: 4
				radius: 20
				y: parent.topPadding + slider.availableHeight / 2 - height / 2
				x: dragArea.x + width / 2

				Rectangle {
					height: slider.height * slider.value - 3
					width: parent.width
					color: Env.colors.secondary
					radius: parent.radius
					anchors.bottom: parent.bottom
				}
			}

			MouseArea {
				id: sliderMouseArea
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				anchors.fill: slider

				onEntered: visibilityHandler.stop()
				onPositionChanged: visibilityHandler.stop()
				onPressed: mouse => mouse.accepted = false
				onWheel: event => {
					let up = event.angleDelta.y > 0;
					if (up) slider.increase();
					else slider.decrease();

					slider.moved();
				}
			}

			onMoved: event => {
				let value = slider.value;
				uiVolume = clampVolume(value);
				if (sink && sink.audio) {
					sink.audio.volume = uiVolume;
				}
			}
		}

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onEntered: visibilityHandler.stop()
			onExited: visibilityHandler.restart()
			z: 1
		}
	}

	Timer {
		id: visibilityHandler
		interval: 2000
		running: false
		onTriggered: root.visible = false
	}
}
