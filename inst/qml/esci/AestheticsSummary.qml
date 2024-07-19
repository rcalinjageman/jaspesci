import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

    Group
    {
    title: qsTr("Summary")
    columns: 2
    Layout.columnSpan: 2

      Esci.ShapeSelect
      {
        label: qsTr("Shape")
        name: "shape_summary"
        id: shape_summary
      }

      Esci.SizeSelect
      {
        label: qsTr("Size")
        name: "size_summary"
      }

      Esci.ColorSelect
      {
        name: "color_summary"
        label: qsTr("Outline")
        startValue: '#008DF9'
        id: color_summary
      }


      Esci.ColorSelect
      {
        name: "fill_summary"
        label: qsTr("Fill")
        startValue: '#008DF9'
        id: fill_summary
      }


      Esci.AlphaSelect
      {
        label: qsTr("Transparency")
        name: "alpha_summary"
      }


    }
