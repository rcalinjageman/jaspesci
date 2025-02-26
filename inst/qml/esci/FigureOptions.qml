import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

  Section
  {
    title: qsTr("Figure options")

    property alias simple_labels_enabled: simple_contrast_labels.enabled
    property alias simple_labels_visible: simple_contrast_labels.visible
    property alias difference_axis_grid_visible: difference_axis_grid.visible
	// property alias difference_axis_units_visible: difference_axis_units.visible
    property bool  difference_axis_units_visible: false
    property alias data_grid_visible: data_grid.visible
    property alias distributions_grid_visible: distributions_grid.visible
    property alias ymin_placeholderText: ymin.placeholderText
    property alias ymax_placeholderText: ymax.placeholderText
    property alias width_defaultValue: width.defaultValue
    property alias height_defaultValue: height.defaultValue
    property alias error_nudge_defaultValue: error_nudge.defaultValue
    property alias data_spread_defaultValue: data_spread.defaultValue
    property alias error_scale_defaultValue: error_scale.defaultValue


    GridLayout
    {
      id: dimensions_grid
      columns: 5
      rowSpacing:    jaspTheme.rowGroupSpacing
      columnSpacing: jaspTheme.columnGroupSpacing

      // 0.7 is obtained via trial and error
      property double adjustedFieldWidth: 0.7 * jaspTheme.textFieldWidth

      // Dimension
      Label { text: qsTr("<b>Dimensions</b>") }

      Label { text: qsTr("Width") }
      IntegerField
      {
        name: "width"
        id: width
        defaultValue: 300
        min: 100
        max: 3000
		fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: qsTr("Height") }
      IntegerField
      {
          name: "height"
          id: height
          defaultValue: 400
          min: 100
          max: 3000
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }
      // end: Dimension

      // y-axis row 1
      Label { text: qsTr("<b><i>Y</i> axis</b>") }

      Label { text: qsTr("Label") }
      TextField
      {
          name: "ylab"
          placeholderText: "auto"
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: "" }
      Label { text: "" }
      // end: y-axis 1

      // y-axis row 2
      Label { text: "" }
      Label { text: qsTr("Tick font size") }
      IntegerField
      {
          name: "axis.text.y"
          defaultValue: 14
          min: 2
          max: 80
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: qsTr("Label font size") }
      IntegerField
      {
          name: "axis.title.y"
          defaultValue: 15
          min: 2
          max: 80
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }
      // end: y-axis row 2

      // y-axis row 3
      Label { text: "" }

      Label { text: qsTr("Min") }
      TextField
      {
          name: "ymin"
          id: ymin
          placeholderText: "auto"
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: qsTr("Max") }
      TextField
      {
          name: "ymax"
          id: ymax
          placeholderText: "auto"
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }
      // end: y-axis row 3

      // y-axis row 4
      Label { text: "" }

      Label { text: qsTr("Num. tick marks") }
      TextField
      {
          name: "ybreaks"
          placeholderText: "auto"
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: "" }
      Label { text: "" }
      // end: y-axis row 4

      // x-axis row 1
      Label { text: qsTr("<b><i>X</i> axis</b>") }

      Label { text: qsTr("Label") }
      TextField
      {
          name: "xlab"
          placeholderText: "auto"
		  fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: "" }
      Label { text: "" }
      // end: x-axis row 1

      // x-axis row 2
      Label { text: "" }

      Label { text: qsTr("Tick font size") }

      IntegerField
      {
        name: "axis.text.x"
        defaultValue: 14
        min: 2
        max: 80
		    fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label { text: qsTr("Label font size") }
      IntegerField
      {
        name: "axis.title.x"
        defaultValue: 15
        min: 2
        max: 80
		    fieldWidth: dimensions_grid.adjustedFieldWidth
      }
      // end: x-axis row 2

      // x-axis row 3
      Label { visible: simple_contrast_labels.visible; text: " " }

      CheckBox {
        name: "simple_contrast_labels";
        id: simple_contrast_labels
        label: qsTr("Simple labels")
        checked: true
      }

      Label { visible: simple_contrast_labels.visible; text: "" }
      Label { visible: simple_contrast_labels.visible; text: "" }
      Label { visible: simple_contrast_labels.visible; text: "" }
      // end: x-axis row 3

      // difference axis row 1
      Label { id: difference_axis_grid; text: qsTr("<b>Difference axis</b>") }

      Label { visible: difference_axis_grid.visible && difference_axis_units_visible; text: qsTr("Units") }
      DropDown
      {
          visible: difference_axis_grid.visible && difference_axis_units_visible
          name: "difference_axis_units"
          Layout.columnSpan: 2
          label: qsTr("Units")
          startValue: 'raw'
          values:
            [
              { label: "Original units", value: "raw"},
              { label: "Standard deviations", value: "sd"}
            ]
      }

      Label { visible: difference_axis_grid.visible; text: qsTr("Num. tick marks") }
      TextField
      {
            visible: difference_axis_grid.visible
            name: "difference_axis_breaks"
            placeholderText: "auto"
			fieldWidth: dimensions_grid.adjustedFieldWidth
      }

        // these two "fill" the row with 5 elements if difference_axis_units_visible is false
      Label { visible: difference_axis_grid.visible && !difference_axis_units_visible; text: "" }
      Label { visible: difference_axis_grid.visible && !difference_axis_units_visible; text: "" }
        // end: difference axis row 1


      // distributions_grid row 1
      Label { id: distributions_grid; text: qsTr("<b>Distributions</b>") }
      Label { visible: distributions_grid_visible; text: qsTr("Width") }
      DoubleField
      {
          visible: distributions_grid_visible
          name: "error_scale"
          id: error_scale
          defaultValue: 0.20
          enabled: effect_size.currentValue === "mean_difference" |  effect_size.currentValue === "mean"
          min: 0
          max: 5
          fieldWidth: dimensions_grid.adjustedFieldWidth
      }

      Label{ visible: distributions_grid_visible; text: qsTr("Style"); enabled: effect_size.currentValue === "mean_difference" |  effect_size.currentValue === "mean" }
      DropDown
      {
          visible: distributions_grid_visible;
          enabled: effect_size.currentValue === "mean_difference" |  effect_size.currentValue === "mean"
          name: "error_layout"

          startValue: 'halfeye'
          values:
              [
                  { label: "Plausibility curve", value: "halfeye"},
                  { label: "Cat's eye", value: "eye"},
                  { label: "None", value: "none"}
              ]
      }
        // end: distributions_grid row 1

      // data grid row 1
      Label { id: data_grid;              text: qsTr("<b>Data</b>"); }
      Label { visible: data_grid.visible; text: qsTr("Layout");      }
      DropDown
      {
        visible: data_grid.visible
        name: "data_layout"
        label: qsTr("Layout")
        startValue: 'random'
        values:
          [
            { label: "Random", value: "random"},
            { label: "Swarm", value: "swarm"},
            { label: "None", value: "none"}
          ]
      }

      Label { visible: data_grid.visible; text: qsTr("Spread"); enabled: from_raw.checked }
      DoubleField
      {
          visible: data_grid.visible
          name: "data_spread"
          id: data_spread
          defaultValue: 0.25
          enabled: from_raw.checked
          min: 0
          max: 5
          fieldWidth: dimensions_grid.adjustedFieldWidth
      }
      // end: data grid row 1

      // data grid row 2
      Label { visible: data_grid.visible; text: " " }
      Label { visible: data_grid.visible; text: qsTr("Offset from CI") }
      DoubleField
      {
          visible: data_grid.visible
          name: "error_nudge"
          id: error_nudge
          defaultValue: 0.3
          enabled: from_raw.checked
          min: 0
          max: 5
        fieldWidth: dimensions_grid.adjustedFieldWidth
      }
      Label { visible: data_grid.visible; text: " " }
      Label { visible: data_grid.visible; text: " " }
      // end: data grid row 2

    }

  }
