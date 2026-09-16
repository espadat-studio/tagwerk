import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Cap-proximity cue for the bar: am I close to the day cap, or not?
//
// A consumer of `tagwerk day --json` and nothing more. The ledger, the
// attribution and the cap verdict all stay in Python: `over_cap` arrives
// already computed (ADR-0011), so no threshold is re-implemented here.
BarWidget {
  id: root
  moduleName: "espadat.tagwerk"

  // The track reaches past the cap, so closing on it is a position to watch
  // rather than a threshold that trips. 1.25 puts the cap notch at 80% of
  // the track and leaves the overrun visible past it.
  readonly property real trackFactor: 1.25
  readonly property real trackLength: Style.space(40)
  readonly property real thickness: Style.space(4)

  readonly property int refreshIntervalSec: setting("refreshIntervalSec", 300)

  property int paidMinutes: 0
  property int totalMinutes: 0
  property int capMinutes: 0
  property bool overCap: false
  property bool loaded: false
  property string failure: ""

  readonly property real trackMinutes: capMinutes * trackFactor

  // Colour's only job. `over_cap` is Python's verdict, so there is no second
  // threshold here and no "approaching" hue: proximity is the fill's length.
  readonly property color fillColor: overCap ? button.activeColor : button.foreground

  function fraction(minutes) {
    return trackMinutes > 0 ? Util.clamp(minutes / trackMinutes, 0, 1) : 0
  }

  function formatHours(minutes) {
    var whole = Math.max(0, Math.round(minutes))
    return Math.floor(whole / 60) + ":" + ("0" + (whole % 60)).slice(-2)
  }

  function refresh() {
    if (!dayProc.running) dayProc.running = true
  }

  function apply(text) {
    try {
      var day = JSON.parse(text)
    } catch (e) {
      root.failure = "day --json did not parse"
      return
    }
    root.paidMinutes = day.paid_minutes
    root.totalMinutes = day.total_minutes
    root.capMinutes = day.cap_minutes
    root.overCap = day.over_cap === true
    root.loaded = true
    root.failure = ""
  }

  readonly property string reading: failure !== ""
    ? "tagwerk: " + failure
    : !loaded
      ? "tagwerk: reading today"
      : "work " + formatHours(paidMinutes)
        + " · personal " + formatHours(totalMinutes - paidMinutes)
        + " · present " + formatHours(totalMinutes)
        + " · " + formatHours(Math.abs(capMinutes - totalMinutes)) + (overCap ? " over" : " left")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: dayProc
    command: ["tagwerk", "day", "--json"]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.apply(text)
    }

    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (text.trim() !== "") console.warn("tagwerk", text.trim())
    }

    // waitForEnd holds `exited` until both streams close, so this lands
    // after apply() and a bad exit wins over whatever it parsed.
    onExited: function(exitCode) {
      if (exitCode !== 0) root.failure = "day --json exited " + exitCode
    }
  }

  Timer {
    interval: root.refreshIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    labelVisible: false
    hasVisualContent: true
    horizontalMargin: 4
    fixedWidth: root.vertical ? -1 : root.trackLength + scaledHorizontalMargin * 2
    fixedHeight: root.vertical ? root.trackLength + scaledVerticalPadding * 2 : -1
    tooltipText: root.reading
    onPressed: if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation tagwerk week")

    // Drawn in horizontal coordinates and turned a quarter for a side bar,
    // which keeps one set of anchors for both orientations.
    Item {
      anchors.centerIn: parent
      width: root.trackLength
      height: root.thickness
      rotation: root.vertical ? 90 : 0

      Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Style.selectedFillFor(button.foreground, Color.accent)
      }

      Rectangle {
        anchors.left: track.left
        anchors.verticalCenter: track.verticalCenter
        height: track.height
        radius: track.radius
        width: track.width * root.fraction(root.totalMinutes)
        color: Util.alpha(root.fillColor, 0.55)

        Behavior on width {
          NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
      }

      // What is left of the translucent fill past this one's right edge
      // is the personal share.
      Rectangle {
        anchors.left: track.left
        anchors.verticalCenter: track.verticalCenter
        height: track.height
        radius: track.radius
        width: track.width * root.fraction(root.paidMinutes)
        color: root.fillColor

        Behavior on width {
          NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
      }

      // The cap, last so the fill arriving does not swallow it.
      Rectangle {
        anchors.verticalCenter: track.verticalCenter
        x: track.width / root.trackFactor
        width: Style.space(1)
        height: track.height
        visible: root.trackMinutes > 0
        color: root.bar ? root.bar.background : Color.bar.background
      }
    }
  }
}
