import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

  Section
  {
    title: qsTr("Figure Options")
    id: figure_options
    property alias simple_contrast_labels_enabled: simple_contrast_labels.enabled
    property alias simple_contrast_labels_visible: simple_contrast_labels.visible
    property alias difference_axis_breaks_enabled: difference_axis_breaks.enabled
    property alias difference_axis_breaks_visible: difference_axis_breaks.visible
    property alias difference_axis_units_enabled: difference_axis_units.enabled
    property alias difference_axis_units_visible: difference_axis_units.visible
    property alias difference_axis_grid_visible: difference_axis_grid.visible

    GridLayout {
      id: fgrid
      columns: 3

      Label {
        text: qsTr("Dimensions")
      }

      IntegerField
      {
        name: "width"
        label: qsTr("Width")
        defaultValue: 300
        min: 100
        max: 3000
      }

    IntegerField
      {
        name: "height"
        label: qsTr("Height")
        defaultValue: 400
        min: 100
        max: 3000
      }

      Label {
        text: qsTr("<i>Y</i> axis")
      }

      TextField
      {
        name: "ylab"
        label: qsTr("Label")
        placeholderText: "auto"
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }

      IntegerField
      {
        name: "axis.text.y"
        label: qsTr("Tick Font Size")
        defaultValue: 14
        min: 2
        max: 80
      }

    IntegerField
      {
        name: "axis.title.y"
        label: qsTr("Label Font Size")
        defaultValue: 15
        min: 2
        max: 80
      }

      Label {
        text: " "
      }

    TextField
      {
        name: "ymin"
        label: qsTr("Min")
        placeholderText: "auto"
        fieldWidth: 60
      }

    TextField
      {
        name: "ymax"
        label: qsTr("Max")
        placeholderText: "auto"
        fieldWidth: 60
      }

      Label {
        text: " "
      }

      TextField
      {
        name: "ybreaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
        fieldWidth: 60
      }

      Label {
        text: " "
      }

      Label {
        text: qsTr("<i>X</i> axis")
      }

      TextField
      {
        name: "xlab"
        label: qsTr("Label")
        placeholderText: "auto"
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }

      IntegerField
      {
        name: "axis.text.x"
        label: qsTr("Tick Font Size")
        defaultValue: 14
        min: 2
        max: 80
      }

    IntegerField
      {
        name: "axis.title.x"
        label: qsTr("Label Font Size")
        defaultValue: 15
        min: 2
        max: 80
      }

      Label {
        text: " "
      }

      CheckBox {
  	    name: "simple_contrast_labels";
  	    id: simple_contrast_labels
	      label: qsTr("Simple labels")
	    }


      Label {
        text: " "
      }

      } // end first grid


      GridLayout {
          id: difference_axis_grid
          columns: 3

          Label {
            text: qsTr("Difference axis")
          }

          Esci.UnitsLayout {
            name: "difference_axis_units"
            id: difference_axis_units
          }

          Label {
            text: " "
          }

          Label {
            text: " "
          }

          TextField
          {
            name: "difference_axis_breaks"
            id: difference_axis_breaks
            label: qsTr("Num. tick marks")
            placeholderText: "auto"
            fieldWidth: 60
          }

          Label {
            text: " "
          }
      }

      GridLayout {
        id: disributions_axis_grid
        columns: 3

        Label {
          text: qsTr("Distributions")
        }

        DoubleField
        {
          name: "error_scale"
          label: qsTr("Width")
          defaultValue: 0.20
          min: 0
          max: 5
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

      Esci.ErrorLayout
        {
          name: "error_layout"
          id: error_layout
        }

        Label {
          text: " "
        }
      } // end distributions grid


      GridLayout {
        id: data_grid
        columns: 3
          Label {
            text: qsTr("Data")
          }

          Esci.DataLayout
          {
            name: "data_layout"
            id: data_layout
            enabled: from_raw.checked
          }


        DoubleField
          {
            name: "data_spread"
            label: qsTr("Layout")
            defaultValue: 0.25
            enabled: from_raw.checked
            min: 0
            max: 5
          }

          Label {
            text: qsTr("Data")
          }


        DoubleField
          {
            name: "error_nudge"
            label: qsTr("Offset from CI")
            defaultValue: 0.3
            enabled: from_raw.checked
            min: 0
            max: 5
          }
      } // end data_grid


}  // end of section
