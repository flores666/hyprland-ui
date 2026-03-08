import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../globals"
import Quickshell.Services.Pipewire

Rectangle {
	id: volumeWidget
	height: parent.height
	color: Env.colors.primary

	IconImage {
		id: image
		width: 10
		height: 10
		anchors.centerIn: parent
		visible: false
	}

	property bool ready: Pipewire.defaultAudioSink?.ready ?? false
	property PwNode sink: Pipewire.defaultAudioSink
	property PwNode source: Pipewire.defaultAudioSource

	// локальное значение для UI (обновляется мгновенно)
	property real uiVolume: (sink && sink.audio) ? sink.audio.volume : 0

	PwObjectTracker {
		objects: [sink, source]
	}

	Connections {
		target: sink ? sink.audio : null
		function onVolumeChanged() {
			if (!sink || !sink.audio) {
				return;
			}
			preventWrongAudioValues();
			uiVolume = sink.audio.volume;   // синхронизируем локальное состояние
			resolveImageSource();
		}
		function onMutedChanged() {
			resolveImageSource();
		}
	}

	onSinkChanged: {
		if (sink && sink.audio) {
			uiVolume = sink.audio.volume;
			resolveImageSource();
		} else {
			uiVolume = 0;
			resolveImageSource();
		}
	}

	Component.onCompleted: {
		if (sink && sink.ready && (isNaN(sink.audio.volume) || sink.audio.volume == null)) {
			sink.audio.volume = 0;
		}
		if (sink && sink.audio) {
			uiVolume = sink.audio.volume;
		} else {
			uiVolume = 0;
		}
		resolveImageSource();
	}

	function preventWrongAudioValues() : void {
		if (!sink || !sink.audio) {
			return;
		}
		sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume));
	}

	function resolveImageSource() : void {
		let offSource = Qt.resolvedUrl("icons/volume_off.svg");
		let midSource = Qt.resolvedUrl("icons/volume_mid.svg");
		let downSource = Qt.resolvedUrl("icons/volume_down.svg");
		let upSource = Qt.resolvedUrl("icons/volume_up.svg");

		if (!sink || !sink.audio) {
			image.source = offSource;
			return;
		}

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
		//cursorShape: Qt.PointingHandCursor
		hoverEnabled: true

		onClicked: {
			if (!sink || !sink.audio) {
				return;
			}
			sink.audio.muted = !sink.audio.muted;
			resolveImageSource();
		}

		onWheel: event => {
			if (!sink || !sink.audio) {
				return;
			}
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
