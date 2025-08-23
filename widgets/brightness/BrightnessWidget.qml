import QtQuick
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

    // буфер быстрых изменений
    property int pendingSteps: 0

    // Получение максимального значения яркости
    Process {
        id: brightMaxProcess
        command: ["brightnessctl", "max"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim()
                if (output !== "") {
                    brightnessWidget.maxBrightness = parseInt(output)
                    brightGetProcess.running = true
                }
                brightMaxProcess.running = false
            }
        }
    }

    // Получение текущей яркости
    Process {
        id: brightGetProcess
        command: ["brightnessctl", "get"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let output = this.text.trim()
                if (output !== "" && brightnessWidget.maxBrightness > 0) {
                    let value = parseInt(output)
                    brightnessWidget.uiBrightness = Math.max(0, Math.min(1, value / brightnessWidget.maxBrightness))
                    brightnessWidget.resolveImageSource()
                }
                brightGetProcess.running = false
            }
        }
    }

    // Процесс увеличения яркости
    Process {
        id: brightPlusProcess
        command: ["brightnessctl", "set", "7%+"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                brightGetProcess.running = true
                brightPlusProcess.running = false
            }
        }
    }

    // Процесс уменьшения яркости
    Process {
        id: brightMinusProcess
        command: ["brightnessctl", "set", "7%-"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                brightGetProcess.running = true
                brightMinusProcess.running = false
            }
        }
    }

    Component.onCompleted: {
        brightMaxProcess.running = true
    }

    function resolveImageSource() {
        let lowSource = Qt.resolvedUrl("icons/brightness_low.svg")
        let midSource = Qt.resolvedUrl("icons/brightness_medium.svg")
        let highSource = Qt.resolvedUrl("icons/brightness_high.svg")

        if (uiBrightness === 0) image.source = lowSource
        else if (uiBrightness < 0.5) image.source = midSource
        else image.source = highSource
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onWheel: event => {
            pendingSteps += event.angleDelta.y > 0 ? 1 : -1
            if (!updateTimer.running) updateTimer.running = true
        }
    }

    // Таймер для буферизации быстрых изменений
    Timer {
        id: updateTimer
        interval: 50
        repeat: true
        running: false
        onTriggered: {
            if (pendingSteps === 0) {
                running = false
                return
            }

            let step = pendingSteps > 0 ? 1 : -1
            pendingSteps -= step

            // Запуск процессов только если они свободны
            if (step > 0 && !brightPlusProcess.running) brightPlusProcess.running = true
            if (step < 0 && !brightMinusProcess.running) brightMinusProcess.running = true

            // Обновление UI локально
            uiBrightness = Math.max(0, Math.min(1, uiBrightness + step * 0.05))
            resolveImageSource()
        }
    }
}

