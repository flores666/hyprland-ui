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
		left: true
		top: true
	}

	margins {
		top: 6
		left: 6
	}

	property real uiBrightness: 0.5;

	function handleBrightnessChange(value) {
		root.visible = true;
		visibilityHandler.restart();
		slider.value = value;
		uiBrightness = value;
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
			value: uiBrightness
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

					/*onPressed: slider.pressed = true
					onReleased: slider.pressed = false

					onPositionChanged: event => {
						var y = parent.y
						// ограничиваем диапазон
						y = Math.max(0, Math.min(slider.height - parent.height, y))

						// вычисляем значение ползунка от 0 до 1 (сверху вниз)
						var value = y / (slider.height - parent.height)
						slider.value = 1 - value
						slider.moved()
						root.sliderChanged(slider.value);
					}*/
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
				/*cursorShape: Qt.PointingHandCursor*/
				anchors.fill: slider

				onEntered: visibilityHandler.stop()
				onPositionChanged: visibilityHandler.stop()
				onPressed: mouse => mouse.accepted = false
				/*onWheel: event => {
					let up = event.angleDelta.y > 0;
					if (up) slider.increase();
					else slider.decrease();

					slider.moved();
					root.sliderChanged(slider.value);
				}*/
			}

			onMoved: event => {
				let value = slider.value;
				if (value >= 0 && value <= 1) uiBrightness = value;
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
