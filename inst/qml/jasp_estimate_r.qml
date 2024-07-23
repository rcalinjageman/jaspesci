//
// Copyright (C) 2013-2018 University of Amsterdam
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./esci" as Esci

Form
{
	id: form
	property int framework:	Common.Type.Framework.Classical
	property alias conf_level_value: conf_level.value

	function alpha_adjust() {
    alpha_label_text = "At alpha = " + Number(1 - (conf_level.value/100)).toLocaleString(Qt.locale("de_DE"), 'f', 4)
  }


  RadioButtonGroup {
    columns: 2
    name: "switch"
    id: switch_source

    RadioButton {
      value: "from_raw";
      label: qsTr("Analyze full data");
      checked: true;
      id: from_raw
    }

    RadioButton {
      value: "from_summary";
      label: qsTr("Analyze summary data");
      id: from_summary
    }
  }



  Section {
    enabled: from_raw.checked
    visible: from_raw.checked
    expanded: from_raw.checked

  	VariablesForm
  	{
  		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
  		AvailableVariablesList { name: "allVariablesList" }
  		AssignedVariablesList { name: "x"; title: qsTr("<i>X</i> Variable"); suggestedColumns: ["scale"]; singleVariable: true }
  		AssignedVariablesList { name: "y"; title: qsTr("<i>Y</i> Variable"); suggestedColumns: ["scale"]; singleVariable: true }
  	}

  }


  Section {
    enabled: from_summary.checked
    visible: from_summary.checked
    expanded: from_summary.checked

    Group {


      GridLayout {
      id: sgrid
      columns: 1

        DoubleField {
          name: "r"
          label: qsTr("Correlation (<i>r</i>)")
          defaultValue: 0.5
          min: 0
          max: 1
          enabled: from_summary.checked
        }


        DoubleField {
          name: "n"
          label: qsTr("Sample size (<i>N</i>)")
          defaultValue: 20
          min: 2
          enabled: from_summary.checked
        }

        TextField
        {
          name: "x_variable_name"
          id: x_variable_name
          label: "X-variable name"
          placeholderText: "X variable"
          enabled: from_summary.checked
        }


        TextField
        {
          name: "y_variable_name"
          id: y_variable_name
          label: "Y-variable name"
          placeholderText: "Y variable"
          enabled: from_summary.checked
        }

      }  // 1 column grid
    }  // end of group for summary

  }

	Group
	{
		title: qsTr("<b>Analysis options</b>")
		Layout.columnSpan: 2
		Esci.ConfLevel
		  {
		    name: "conf_level"
		    id: conf_level
		    onFocusChanged: {
         alpha_adjust()
        }
		  }

	}

	Group
	{
	  title: qsTr("<b>Results options</b>")
	  CheckBox
	  {
	    name: "show_details";
	    label: qsTr("Extra details")
	   }
  }


  Group {
    title: qsTr("<b>Regression</b>")
    enabled: from_raw.checked
    visible: from_raw.checked
    Layout.columnSpan: 2

    CheckBox
	  {
	    name: "do_regression";
	    id: do_regression
	    label: qsTr("Regression analysis")
	    enabled: from_raw.checked
      visible: from_raw.checked
	   }

	  GridLayout {
	    columns: 3

	      CheckBox {
    	    name: "show_line";
    	    id: show_line
	        label: qsTr("Line")
	        enabled: do_regression.checked
          visible: from_raw.checked
	      }

	      CheckBox {
    	    name: "show_line_CI";
    	    id: show_line_CI
	        label: qsTr("CI on Line")
	        enabled: do_regression.checked
          visible: from_raw.checked
	      }

	      CheckBox {
    	    name: "show_residuals";
    	    id: show_residuals
	        label: qsTr("Residuals")
	        enabled: do_regression.checked
          visible: from_raw.checked
	      }
	  }

    CheckBox
	  {
	    name: "show_PI";
	    id: show_PI
	    label: qsTr("Prediction interval")
	    enabled: do_regression.checked
      visible: from_raw.checked
	   }

	   TextField {
         name: "predict_from_x"
         id: predict_from_x
         label: qsTr("Enter <i>X</i> value to generate prediction (<i>&#374;</i>)")
         placeholderText: "Enter an X value"
   	     enabled: do_regression.checked
         visible: from_raw.checked
     }

  }


    Section
  {
    title: qsTr("Scatterplot options")
    enabled: from_raw.checked
    visible: from_raw.checked


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
        defaultValue: 300
        min: 100
        max: 3000
      }

    IntegerField
      {
        name: "sp_plot_height"
        id: sp_plot_height
        label: qsTr("Height")
        defaultValue: 400
        min: 100
        max: 3000
      }
    }  // end dimensions grid


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


    Section
  {
    title: qsTr("Scatterplot aesthetics")
    enabled: from_raw.checked
    visible: from_raw.checked

     GridLayout {
      id: sp_raw_grid
      columns: 1
      Layout.columnSpan: 2

      Label {
          text: qsTr("Raw data")
      }

      Esci.ShapeSelect
      {
        name: "sp_shape_raw_reference"
        id: sp_shape_raw_reference
        label: qsTr("Shape")
        startValue: 'circle filled'
        enabled: from_raw.checked
      }

      Esci.SizeSelect
      {
        name: "sp_size_raw_reference"
        id: sp_size_raw_reference
        label: qsTr("Size")
        defaultValue: 3
        enabled: from_raw.checked

      }

      Esci.ColorSelect
      {
        name: "sp_color_raw_reference"
        id: sp_color_raw_reference
        label: qsTr("Outline")
        startValue: "black"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_fill_raw_reference"
        id: sp_fill_raw_reference
        label: qsTr("Fill")
        startValue: "#008DF9"
        enabled: from_raw.checked
      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_raw_reference"
        label: qsTr("Transparency")
        id: sp_alpha_raw_reference
        enabled: from_raw.checked
      }


    }

    GridLayout {
      id: sp_linetypes_grid
      columns: 4
      Layout.columnSpan: 2
      enabled: do_regression.checked

      Label {
          text: ""
      }

      Label {
          text: qsTr("Regression")
      }

      Label {
          text: qsTr("Prediction")
      }


      Label {
          text: qsTr("Residual")
      }

      Label {
          text: "Style"
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_summary_reference"
        id: sp_linetype_summary_reference
        enabled: show_line.checked
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_PI_reference"
        id: sp_linetype_PI_reference
        enabled: show_PI.checked
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_residual_reference"
        id: sp_linetype_residual_reference
        enabled: show_residuals.checked
      }

      Label {
          text: "Thickness"
      }

      IntegerField
      {
        name: "sp_size_interval_reference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: show_line.checked
      }

      IntegerField
      {
        name: "sp_size_PI_reference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: show_PI.checked
      }

      IntegerField
      {
        name: "sp_size_residual_reference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: show_residuals.checked
      }



    }

  }



  Esci.FigureOptions {
    title: qsTr("Estimation figure options")
    simple_labels_enabled: false
    simple_labels_visible: false
    difference_axis_grid_visible: false
    difference_axis_units_visible: false
    data_grid_visible: false
    distributions_grid_visible: false
    ymin_placeholderText: "-1"
    ymax_placeholderText: "1"
    width_defaultValue: 300
    height_defaultValue: 400

  }


    Section
  {
    title: qsTr("Estimation figure aesthetics")

    Esci.AestheticsSummary {
    }

    Group
    {
    title: qsTr("CI")
    columns: 2
    Layout.columnSpan: 2

      Esci.LineTypeSelect
      {
        label: qsTr("Style")
        name: "linetype_summary"
        id: linetype_summary
      }

      IntegerField
      {
        name: "size_interval"
        label: qsTr("Thickness")
        defaultValue: 3
        min: 1
        max: 10
      }

      Esci.ColorSelect
      {
        name: "color_interval"
        label: qsTr("Color")
        startValue: 'black'
        id: color_interval
      }

      Esci.AlphaSelect
      {
        name: "alpha_interval"
        label: qsTr("Transparency")
      }
    }  // end ci grid



  }


  Esci.HeOptions {
    null_value_enabled: true
    null_boundary_max: 1
  }


}
