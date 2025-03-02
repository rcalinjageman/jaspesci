import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci


  Section
  {
    title: qsTr("Scatterplot options")
    enabled: from_raw.checked
    visible: from_raw.checked

    property alias sp_other_options_grid_enabled: sp_other_options_grid.enabled
    property alias sp_other_options_grid_visible: sp_other_options_grid.visible
    property alias histogram_grid_visible: histogram_grid.visible
    property alias sp_plot_width_defaultValue: sp_plot_width.defaultValue
    property alias sp_plot_height_defaultValue: sp_plot_height.defaultValue



    GridLayout {
      id: sp_dimensions_grid
      columns: 5
      Layout.columnSpan: 2
      rowSpacing:    jaspTheme.rowGroupSpacing
      columnSpacing: jaspTheme.columnGroupSpacing


      Label {
        text: qsTr("<b>Dimensions</b>")
      }


      Label {
        text: qsTr("Width")
      }

      IntegerField
      {
        name: "sp_plot_width"
        id: sp_plot_width
        defaultValue: 650
        min: 100
        max: 3000
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }

      Label {
        text: qsTr("Height")
      }

    IntegerField
      {
        name: "sp_plot_height"
        id: sp_plot_height
        defaultValue: 650
        min: 100
        max: 3000
        fieldWidth: jaspTheme.textFieldWidth * 0.7
      }
    }  // end dimensions grid



    GridLayout {
      id: histogram_grid
      columns: 5
      Layout.columnSpan: 2
      visible: false
      rowSpacing:    jaspTheme.rowGroupSpacing
      columnSpacing: jaspTheme.columnGroupSpacing

        Label {
          text: qsTr("<b>Histogram</b>")
        }

        Label {
          text: qsTr("No. bins")
        }

        IntegerField
        {
          name: "histogram_bins"
          defaultValue: 12
          min: 2
          max: 80
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: qsTr(" ")
        }

        Label {
          text: qsTr(" ")
        }


    }  // end histogram


    GridLayout {
      id: sp_yaxis_grid
      columns: 5
      Layout.columnSpan: 2
      rowSpacing:    jaspTheme.rowGroupSpacing
      columnSpacing: jaspTheme.columnGroupSpacing

        Label {
          text: qsTr("<b><i>Y</i> axis</b>")
        }

        Label {
          text: qsTr("Label")
        }

        TextField
        {
          name: "sp_ylab"
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7 * 2
          Layout.columnSpan: 3
        }


        Label {
          text: " "
        }

        Label {
          text: qsTr("Tick Font Size")
        }

        IntegerField
        {
          name: "sp_axis.text.y"
          defaultValue: 14
          min: 2
          max: 80
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text:  qsTr("Label Font Size")
        }

      IntegerField
        {
          name: "sp_axis.title.y"
          defaultValue: 15
          min: 2
          max: 80
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: " "
        }

        Label {
          text: qsTr("Min")
        }

      TextField
        {
          name: "sp_ymin"
          id: ymin
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: qsTr("Max")
        }

      TextField
        {
          name: "sp_ymax"
          id: ymax
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: " "
        }


        Label {
          text: qsTr("Num. tick marks")
        }


        TextField
        {
          name: "sp_ybreaks"
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

      } // yaxis grid


      GridLayout {
      id: sp_xaxiss_grid
      columns: 5
      Layout.columnSpan: 2
      rowSpacing:    jaspTheme.rowGroupSpacing
      columnSpacing: jaspTheme.columnGroupSpacing


        Label {
          text: qsTr("<b><i>X</i> axis</b>")
        }


        Label {
          text: qsTr("Label")
        }

        TextField
        {
          name: "sp_xlab"
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7 * 2
          Layout.columnSpan: 3
        }

        Label {
          text: " "
        }

        Label {
          text: qsTr("Tick Font Size")
        }

        IntegerField
        {
          name: "sp_axis.text.x"
          defaultValue: 14
          min: 2
          max: 80
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: qsTr("Label Font Size")
        }


      IntegerField
        {
          name: "sp_axis.title.x"
          defaultValue: 15
          min: 2
          max: 80
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: " "
        }

        Label {
          text:  qsTr("Min")
        }

      TextField
        {
          name: "sp_xmin"
          id: xmin
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text:  qsTr("Max")
        }

      TextField
        {
          name: "sp_xmax"
          id: xmax
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: " "
        }

        Label {
          text:  qsTr("Num. tick marks")
        }


        TextField
        {
          name: "sp_xbreaks"
          placeholderText: "auto"
          fieldWidth: jaspTheme.textFieldWidth * 0.7
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

      } // xaxis grid


      GridLayout {
      id: sp_other_options_grid
      columns: 3
      Layout.columnSpan: 2

        Label {
          text: qsTr("<b>Other options</b>")
        }

        CheckBox
    	  {
    	    name: "show_mean_lines";
    	    label: qsTr("Cross through means of <i>X</i> and <i>Y</i>")
    	    enabled: from_raw.checked
          visible: from_raw.checked
    	   }

    	  CheckBox
    	  {
    	    name: "plot_as_z";
    	    label: qsTr("<i>Z</i> scores rather than raw scores")
    	    enabled: from_raw.checked
          visible: from_raw.checked
    	   }

        Label {
          text: qsTr("")
        }

    	  CheckBox
    	  {
    	    name: "show_r";
    	    label: qsTr("<i>r</i> value on scatterplot")
    	    enabled: from_raw.checked
          visible: from_raw.checked
    	   }

        Label {
          text: qsTr("")
        }

      }

  }
