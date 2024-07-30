import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

  Section
  {
    title: qsTr("Figure Options")

    property alias simple_labels_enabled: simple_contrast_labels.enabled
    property alias simple_labels_visible: simple_contrast_labels.visible
    property alias difference_axis_grid_visible: difference_axis_grid.visible
    property alias difference_axis_units_visible: difference_axis_units.visible
    property alias data_grid_visible: data_grid.visible
    property alias distributions_grid_visible: distributions_grid.visible
    property alias ymin_placeholderText: ymin.placeholderText
    property alias ymax_placeholderText: ymax.placeholderText
    property alias width_defaultValue: width.defaultValue
    property alias height_defaultValue: height.defaultValue
    property alias error_nudge_defaultValue: error_nudge.defaultValue
    property alias data_spread_defaultValue: data_spread.defaultValue
    property alias error_scale_defaultValue: error_scale.defaultValue


    GridLayout {
      id: dimensions_grid
      columns: 3
      Layout.columnSpan: 2

      Label {
        text: qsTr("Dimensions")
      }

      IntegerField
      {
        name: "width"
        id: width
        label: qsTr("Width")
        defaultValue: 300
        min: 100
        max: 3000
      }

    IntegerField
      {
        name: "height"
        id: height
        label: qsTr("Height")
        defaultValue: 400
        min: 100
        max: 3000
      }
    }  // end dimensions grid


    GridLayout {
      id: yaxis_grid
      columns: 3
      Layout.columnSpan: 2


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
          id: ymin
          label: qsTr("Min")
          placeholderText: "auto"
          fieldWidth: 60
        }

      TextField
        {
          name: "ymax"
          id: ymax
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

      } // yaxis grid


      GridLayout {
      id: xaxiss_grid
      columns: 3
      Layout.columnSpan: 2


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
	      checked: true
	    }


        Label {
          text: " "
        }

      } // xaxis grid



      GridLayout {
      id: difference_axis_grid
      columns: 3
      Layout.columnSpan: 2
        Label {
          text: qsTr("Difference axis")
        }

             DropDown
        {
          name: "difference_axis_units"
          id: difference_axis_units
          Layout.columnSpan: 2
          label: qsTr("Units")
          startValue: 'raw'
          values:
            [
              { label: "Original units", value: "raw"},
              { label: "Standard deviations", value: "sd"}
            ]
        }

        Label {
          text: " "
        }

        TextField
        {
          name: "difference_axis_breaks"
          label: qsTr("Num. tick marks")
          placeholderText: "auto"
        }

        Label {
          text: " "
        }
      } // difference axis grid


      GridLayout {
      id: distributions_grid
      columns: 3
      Layout.columnSpan: 2

        Label {
          text: qsTr("Distributions")
        }

        DoubleField
        {
          name: "error_scale"
          id: error_scale
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

    }  // end distributions grid


    GridLayout {
      id: data_grid
      columns: 3
      Layout.columnSpan: 2


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
        id: data_spread
        label: qsTr("Spread")
        defaultValue: 0.25
        enabled: from_raw.checked
        min: 0
        max: 5
      }

      Label {
        text: ""
      }


    DoubleField
      {
        name: "error_nudge"
        id: error_nudge
        label: qsTr("Offset from CI")
        defaultValue: 0.3
        enabled: from_raw.checked
        min: 0
        max: 5
      }


    } // end data grid

  }
