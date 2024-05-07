import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

      DropDown
      {
        label: qsTr("Style")
        startValue: 'halfeye'
        values:
          [
            { label: "Plausibility curve", value: "halfeye"},
            { label: "Cat's eye", value: "eye"},
            { label: "None", value: "none"}
          ]
      }
