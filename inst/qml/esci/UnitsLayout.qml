import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

      DropDown
      {
        label: qsTr("Units")
        startValue: 'raw'
        values:
          [
            { label: "Original units", value: "raw"},
            { label: "Standard deviations", value: "sd"}
          ]
      }

