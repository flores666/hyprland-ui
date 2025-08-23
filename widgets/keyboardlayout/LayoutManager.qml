pragma Singleton

import QtQuick
import Quickshell.Hyprland
import Quickshell
import Quickshell.Io

Singleton {
	id: layoutService

	property string currentLayout: "";
	property bool capsLockActive: false;

	function parseLayout(fullLayoutName) {
		if (!fullLayoutName) return;

		const shortName = fullLayoutName.substring(0, 2).toLowerCase();

		if (currentLayout !== shortName) {
			currentLayout = shortName;
		}
	}

	function handleRawEvent(event) {
		if (event.name === "activelayout") {
			const dataString = event.data;
			const layoutInfo = dataString.split(",");
			const fullLayoutName = layoutInfo[layoutInfo.length - 1];

			parseLayout(fullLayoutName);
		}
	}

	Process {
		id: initProcess
		running: true
		command: [
			"sh", "-c",
			"hyprctl devices -j | jq -r '.keyboards[] | .active_keymap' | head -n1 | cut -c1-2 | tr 'A-Z' 'a-z'"
		]
		stdout: StdioCollector {
			onStreamFinished: {
				const output = this.text.trim();
				if (output.length > 0) {
					layoutService.currentLayout = output;
				}
			}
		}
	}

	Timer {
		interval: 200
		running: true
		repeat: true
		onTriggered: capsProcess.running = true;
	}

	Process {
		id: capsProcess
		command: [
			"sh", "-c",
			"cat /sys/class/leds/*::capslock/brightness | head -n1"
		]
		stdout: StdioCollector {
			onStreamFinished: {
				const text = this.text.trim()
				layoutService.capsLockActive = (text === "1")

				if (layoutService.capsLockActive)
				layoutService.currentLayout = layoutService.currentLayout.toUpperCase()
				else
				layoutService.currentLayout = layoutService.currentLayout.toLowerCase()
			}
		}

		Component.onCompleted: {
			Hyprland.rawEvent.connect(handleRawEvent);
		}
	}
}
