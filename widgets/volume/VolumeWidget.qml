import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../globals"
import Quickshell.Services.Pipewire

Rectangle {
	id: volumeWidget
	height: parent.height
	width: parent.width * 0.1
	color: Env.colors.primary

	IconImage {
		id: image
		source: Qt.resolvedUrl("icons/volume.svg")
		width: 21
		height: 21
		anchors.centerIn: parent
	}

	property bool ready: Pipewire.defaultAudioSink?.ready ?? false
	property PwNode sink: Pipewire.defaultAudioSink
	property PwNode source: Pipewire.defaultAudioSource

	// локальное значение для UI (обновляется мгновенно)
	property real uiVolume: sink.audio.volume

	PwObjectTracker {
		objects: [sink, source]
	}

	Connections {
		target: sink.audio
		function onVolumeChanged() {
			preventWrongAudioValues();
			uiVolume = sink.audio.volume;   // синхронизируем локальное состояние
			resolveImageSource();
		}
		function onMutedChanged() {
			resolveImageSource();
		}
	}

	Component.onCompleted: {
		if (sink.ready && (isNaN(sink.audio.volume) || sink.audio.volume == null)) {
			sink.audio.volume = 0;
		}
		uiVolume = sink.audio.volume;
		resolveImageSource();
	}

	function preventWrongAudioValues() : void {
		sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume));
	}

	function resolveImageSource() : void {
		let offSource = Qt.resolvedUrl("icons/volume_off.svg");
		let midSource = Qt.resolvedUrl("icons/volume_mid.svg");
		let downSource = Qt.resolvedUrl("icons/volume_down.svg");
		let upSource = Qt.resolvedUrl("icons/volume_up.svg");

		if (sink.audio.muted) {
			image.source = offSource;
			return;
		}

		if (uiVolume === 0) {
			image.source = downSource;
		} else if (uiVolume < 0.5) {
			image.source = midSource;
		} else {
			image.source = upSource;
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true

		onClicked: {
			sink.audio.muted = !sink.audio.muted;
			resolveImageSource();
		}

		onWheel: event => {
			if (!sink.audio.muted) {
				let step = 0.05;
				let up = event.angleDelta.y > 0;

				if (up) uiVolume = Math.min(1, uiVolume + step);
				else uiVolume = Math.max(0, uiVolume - step);

				// моментально меняем UI
				resolveImageSource();

				// и отправляем новое значение в Pipewire
				sink.audio.volume = uiVolume;
			}
		}
	}

	VolumeScrollBar {}
}

