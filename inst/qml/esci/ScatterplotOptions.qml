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
      columns: 3
      Layout.columnSpan: 2

      Label {
        text: qsTr("Dimensions")
      }

      IntegerField
      {
        name: "sp_plot_width"
        id: sp_plot_width
        label: qsTr("Width")
        defaultValue: 650
        min: 100
        max: 3000
      }

    IntegerField
      {
        name: "sp_plot_height"
        id: sp_plot_height
        label: qsTr("Height")
        defaultValue: 650
        min: 100
        max: 3000
      }
    }  // end dimensions grid

    GridLayout {
      id: histogram_grid
      columns: 3
      Layout.columnSpan: 2
      visible: false

        Label {
          text: qsTr("Histogram")
        }

        IntegerField
        {
          name: "histogram_bins"
          label: qsTr("No. bins")
          defaultValue: 12
          min: 2
          max: 80
        }


    }  // end histogram


    GridLayout {
      id: sp_yaxis_grid
      columns: 3
      Layout.columnSpan: 2


        Label {
          text: qsTr("<i>Y</i> axis")
        }

        TextField
        {
          name: "sp_ylab"
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
          name: "sp_axis.text.y"
          label: qsTr("Tick Font Size")
          defaultValue: 14
          min: 2
          max: 80
        }

      IntegerField
        {
          name: "sp_axis.title.y"
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
          name: "sp_ymin"
          id: ymin
          label: qsTr("Min")
          placeholderText: "auto"
          fieldWidth: 60
        }

      TextField
        {
          name: "sp_ymax"
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
          name: "sp_ybreaks"
          label: qsTr("Num. tick marks")
          placeholderText: "auto"
          fieldWidth: 60
        }

        Label {
          text: " "
        }

      } // yaxis grid


      GridLayout {
      id: sp_xaxiss_grid
      columns: 3
      Layout.columnSpan: 2


        Label {
          text: qsTr("<i>X</i> axis")
        }

        TextField
        {
          name: "sp_xlab"
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
          name: "sp_axis.text.x"
          label: qsTr("Tick Font Size")
          defaultValue: 14
          min: 2
          max: 80
        }

      IntegerField
        {
          name: "sp_axis.title.x"
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
          name: "sp_xmin"
          id: xmin
          label: qsTr("Min")
          placeholderText: "auto"
          fieldWidth: 60
        }

      TextField
        {
          name: "sp_xmax"
          id: xmax
          label: qsTr("Max")
          placeholderText: "auto"
          fieldWidth: 60
        }

        Label {
          text: " "
        }

        TextField
        {
          name: "sp_xbreaks"
          label: qsTr("Num. tick marks")
          placeholderText: "auto"
          fieldWidth: 60
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
          text: qsTr("Other options")
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
