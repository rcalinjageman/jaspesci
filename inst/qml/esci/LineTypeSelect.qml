import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

      DropDown
      {
        label: qsTr("Style")
        startValue: 'solid'
        values:
          [
            { label: "Solid", value: "solid"},
            { label: "Dotted", value: "dotted"},
            { label: "Dotdash", value: "dotdash"},
            { label: "Dashed", value: "dashed"},
            { label: "Blank", value: "blank"}
          ]
      }
