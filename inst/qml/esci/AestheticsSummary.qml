import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

    GridLayout
    {
    columns: 5
    Layout.columnSpan: 2
    rowSpacing:    jaspTheme.rowGroupSpacing
    columnSpacing: jaspTheme.columnGroupSpacing

    Label { text: qsTr("<b>Summary</b>") }

    Label { text: qsTr("Shape") }

      Esci.ShapeSelect
      {
        name: "shape_summary"
        id: shape_summary
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }

    Label { text: qsTr("Size") }

      Esci.SizeSelect
      {
        name: "size_summary"
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }

    Label { text: qsTr(" ") }

    Label { text: qsTr("Outline") }

      Esci.ColorSelect
      {
        name: "color_summary"
        startValue: '#008DF9'
        id: color_summary
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }

    Label { text: qsTr("Fill") }

      Esci.ColorSelect
      {
        name: "fill_summary"
        label: qsTr("Fill")
        startValue: '#008DF9'
        id: fill_summary
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }

    Label { text: qsTr(" ") }

    Label { text: qsTr("Transparency") }


      Esci.AlphaSelect
      {
        name: "alpha_summary"
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }

      Label { text: qsTr(" ") }

      Label { text: qsTr(" ") }


    }
