import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

	Section
  {
    title: qsTr("Hypothesis evaluation")

    Group
    {
      Layout.columnSpan: 2

      CheckBox
      {
      name: "evaluate_hypotheses"
      label: qsTr("Hypothesis evaluation")
      id: evaluate_hypotheses
      }

    }

    GridLayout {
      id: hgrid
      columns: 3

      DoubleField
      {
        name: "null_value"
        label: qsTr("Evaluate against <i>H</i><sub>0</sub> of: ")
        defaultValue: 0
        id: null_value
        negativeValues: true
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
      }

      DoubleField
      {
        name: "null_boundary"
        id: null_boundary
        label: qsTr("+/- ")
        defaultValue: 0
        negativeValues: false
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
      }

      Label {
        text: "at alpha = .05"
        id: alpha_label
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
      }

      Esci.ColorSelect
      {
        name: "null_color"
        label: qsTr("Color for null hypothesis")
        startValue: '#A40122'
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
        id: null_color
      }


    }  // end HE grid


  }  // end HE section
