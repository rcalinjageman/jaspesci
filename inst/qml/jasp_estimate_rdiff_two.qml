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
  		AssignedVariablesList { name: "grouping_variable"; title: qsTr("Grouping variable"); suggestedColumns: ["nominal"]; singleVariable: true }
  	}

  }


  Section {
    enabled: from_summary.checked
    visible: from_summary.checked
    expanded: from_summary.checked

    Group {


      GridLayout {
      id: sgrid
      columns: 3

        Label {
          text: qsTr("")
        }

        Label {
          text: qsTr("<b>Reference group</b>")
        }

        Label {
          text: qsTr("<b>Comparison group</b>")
        }

        Label {
          text: qsTr("Name")
        }

        TextField
        {
          name: "reference_level_name"
          id: reference_level_name
          label: ""
          placeholderText: "Reference level"
          enabled: from_summary.checked
        }


        TextField
        {
          name: "comparison_level_name"
          id: comparison_level_name
          label: ""
          placeholderText: "Comparison level"
          enabled: from_summary.checked
        }

        Label {
          text: qsTr("Correlation (<i>r</i>)")
        }

        DoubleField {
          name: "reference_r"
          label: ""
          defaultValue: 0.5
          min: 0
          max: 1
          enabled: from_summary.checked
        }

        DoubleField {
          name: "comparison_r"
          label: ""
          defaultValue: 0.75
          min: 0
          max: 1
          enabled: from_summary.checked
        }


        Label {
          text: qsTr("Sample size (<i>N</i>)")
        }

        DoubleField {
          name: "reference_n"
          label: ""
          defaultValue: 20
          min: 2
          enabled: from_summary.checked
        }


        DoubleField {
          name: "comparison_n"
          label: ""
          defaultValue: 20
          min: 2
          enabled: from_summary.checked
        }

      } // end of 3 column grid


      GridLayout {
      id: slabelgrid
      columns: 1

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

        TextField
        {
          name: "grouping_variable_name"
          id: grouping_variable_name
          label: "Grouping variable name"
          placeholderText: "Grouping variable"
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

	  GridLayout {
	    columns: 2

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

	  }


  } // end of regression


  Esci.ScatterplotOptions {
    sp_other_options_grid_enabled: false
    sp_other_options_grid_visible: false
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
        defaultValue: 75
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
        startValue: "dotted"
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
        name: "sp_size_summary_reference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: show_line.checked
      }

      IntegerField
      {
        name: "sp_size_PI_reference"
        defaultValue: 2
        min: 1
        max: 10
        enabled: show_PI.checked
      }

      IntegerField
      {
        name: "sp_size_residual_reference"
        defaultValue: 1
        min: 1
        max: 10
        enabled: show_residuals.checked
      }

      Label {
          text: "Color"
      }


      Esci.ColorSelect
      {
        name: "sp_color_summary_reference"
        id: sp_color_summary_reference
        startValue: '#008DF9'
        enabled: show_line.checked || show_line_CI.checked
      }

      Esci.ColorSelect
      {
        name: "sp_color_PI_reference"
        id: sp_color_PI_reference
        startValue: '#E20134'
        enabled: show_PI.checked
      }

      Esci.ColorSelect
      {
        name: "sp_color_residual_reference"
        id: sp_color_residual_reference
        startValue: '#E20134'
        enabled: show_residuals.checked
      }


      Label {
          text: "Transparency"
      }


      Esci.AlphaSelect
      {
        name: "sp_alpha_summary_reference"
        id: sp_alpha_summary_reference
        enabled: show_line_CI.checked
        defaultValue: 75
      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_PI_reference"
        id: sp_alpha_PI_reference
        enabled: show_PI.checked
      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_residual_reference"
        id: sp_alpha_residual_reference
        enabled: show_residuals.checked
      }


    } // end linetypes grid of scatterplot aesthetics

    GridLayout {
      id: sp_predict_from_x_grid
      columns: 1
      Layout.columnSpan: 2

      Label {
          text: qsTr("Prediction from <i>X</i>")
      }

      IntegerField
      {
        name: "sp_prediction_label"
        defaultValue: 5
        label: qsTr("Label size")
        min: 1
        max: 10
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_prediction_color"
        id: sp_prediction_color
        label: qsTr("Label color")
        startValue: "#E20134"
        enabled: from_raw.checked
      }


    }  // end predict from x grid

    GridLayout {
      id: sp_guidelines_grid
      columns: 4
      Layout.columnSpan: 2
      enabled: do_regression.checked

      Label {
          text: ""
      }

      Label {
          text: qsTr("Guidelines")
      }

      Label {
          text: qsTr("PI")
      }


      Label {
          text: qsTr("SI")
      }

      Label {
          text: "Style"
      }


      Esci.LineTypeSelect
      {
        name: "sp_linetype_ref"
        id: sp_linetype_ref
        enabled: from_raw.checked
        startValue: "dotted"
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_PI"
        id: sp_linetype_PI
        enabled: show_PI.checked
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_CI"
        id: sp_linetype_CI
        enabled: show_line_CI.checked
      }

      Label {
          text: "Thickness"
      }

      IntegerField
      {
        name: "sp_size_ref"
        defaultValue: 1
        min: 1
        max: 10
        enabled: from_raw.checked
      }

      IntegerField
      {
        name: "sp_size_PI"
        defaultValue: 2
        min: 1
        max: 10
        enabled: show_PI.checked
      }

      IntegerField
      {
        name: "sp_size_CI"
        defaultValue: 4
        min: 1
        max: 10
        enabled: show_line_CI
      }

      Label {
          text: "Color"
      }


      Esci.ColorSelect
      {
        name: "sp_color_ref"
        id: sp_color_ref
        startValue: 'gray60'
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_color_PI"
        id: sp_color_PI
        startValue: '#E20134'
        enabled: show_PI.checked
      }

      Esci.ColorSelect
      {
        name: "sp_color_CI"
        id: sp_color_CI
        startValue: '#008DF9'
        enabled: show_line_CI.checked
      }


      Label {
          text: "Transparency"
      }


      Esci.AlphaSelect
      {
        name: "sp_alpha_ref"
        id: sp_alpha_ref
        enabled: from_raw.checked
      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_PI"
        id: sp_alpha_PI
        enabled: show_PI.checked
      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_CI"
        id: sp_alpha_CI
        enabled: show_line_CI.checked
      }

    }

  }



  Esci.FigureOptions {
    title: qsTr("Estimation figure options")
    simple_labels_enabled: false
    simple_labels_visible: false
    difference_axis_grid_visible: true
    difference_axis_units_visible: false
    data_grid_visible: false
    distributions_grid_visible: false
    ymin_placeholderText: "-1"
    ymax_placeholderText: "1"
    width_defaultValue: 600
    height_defaultValue: 400

  }


    Section
  {
    title: qsTr("Estimation figure aesthetics")

    Esci.AestheticsSummaryByGroup {
      Layout.columnSpan: 2
    }


    GridLayout {
      id: aesthetics_summary_by_group
      columns: 4

      Label {
        text: qsTr("CI")
        Layout.columnSpan: 4
      }

      Label {
        text: qsTr("Style")
      }

      Esci.LineTypeSelect
      {
        name: "linetype_summary_reference"
        id: linetype_summary_reference
      }

      Esci.LineTypeSelect
      {
        name: "linetype_summary_comparison"
        id: linetype_summary_comparison
      }

      Esci.LineTypeSelect
      {
        name: "linetype_summary_difference"
        id: linetype_summary_difference
      }



    }


  }


  Esci.HeOptions {
    null_value_enabled: false
    null_boundary_max: 1
  }


}
