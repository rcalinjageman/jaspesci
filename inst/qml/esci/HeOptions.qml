import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

	Section
  {
    title: qsTr("Hypothesis evaluation")

    property alias null_value_enabled: null_value.enabled
    property alias null_value_min: null_value.min
    property alias null_value_max: null_value.max
    property alias null_value_negativeValues: null_value.negativeValues
    property alias null_boundary_max: null_boundary.max
    property alias alpha_label_text: alpha_label.text

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
        min: -Infinity
        max: Infinity
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
        max: Infinity
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
