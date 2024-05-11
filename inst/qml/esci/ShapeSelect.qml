import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

      DropDown
      {
        startValue: 'circle filled'
        values:
          [
            { label: "Circle", value: "circle filled"},
            { label: "Square", value: "square filled"},
            { label: "Diamond", value: "diamond filled"},
            { label: "Triangle", value: "triangle filled"}
          ]
      }
