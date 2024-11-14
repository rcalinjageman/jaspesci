import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci


    GridLayout {
      id: aesthetics_summary_by_group
      columns: 4


      Label {
        text: " "
      }

      Label {
        text: "<u>Reference</u>"
      }


      Label {
        text: "<u>Comparison</u>"
      }


      Label {
        text: "<u>Difference</u>"
      }

      Label {
        text: "<b>Summary</b>"
        Layout.columnSpan: 4
      }

      Label {
        text: qsTr("Shape")
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_reference"
        id: shape_summary_reference
        startValue: 'circle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_comparison"
        id: shape_summary_comparison
        startValue: 'circle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_difference"
        id: shape_summary_difference
        startValue: 'triangle filled'
      }

      Label {
        text: qsTr("Size")
      }

      Esci.SizeSelect
      {
        name: "size_summary_reference"
        id: size_summary_reference

      }

      Esci.SizeSelect
      {
        name: "size_summary_comparison"
        id: size_summary_comparison

      }

      Esci.SizeSelect
      {
        name: "size_summary_difference"
        id: size_summary_difference

      }

      Label {
        text: qsTr("Outline")
      }

      Esci.ColorSelect
      {
        name: "color_summary_reference"
        id: color_summary_reference
        startValue: "#008DF9"
      }

      Esci.ColorSelect
      {
        name: "color_summary_comparison"
        id: color_summary_comparison
        startValue: "#009F81"
      }

      Esci.ColorSelect
      {
        name: "color_summary_difference"
        id: color_summary_difference
        startValue: 'black'
      }

      Label {
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_summary_reference"
        id: fill_summary_reference
        startValue: "#008DF9"
      }

      Esci.ColorSelect
      {
        name: "fill_summary_comparison"
        id: fill_summary_comparison
        startValue: "#009F81"
      }

      Esci.ColorSelect
      {
        name: "fill_summary_difference"
        id: fill_summary_difference
        startValue: 'black'
      }

      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_reference"
        id: alpha_summary_reference

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_comparison"
        id: alpha_summary_comparison

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_difference"
        id: alpha_summary_difference

      }
  }
