import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

      DropDown
      {
        label: qsTr("Layout")
        startValue: 'random'
        values:
          [
            { label: "Random", value: "random"},
            { label: "Swarm", value: "swarm"},
            { label: "None", value: "none"}
          ]
      }
