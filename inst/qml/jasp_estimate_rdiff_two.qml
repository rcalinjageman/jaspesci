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
	  myHeOptions.currentConfLevel = conf_level.value
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
  		AssignedVariablesList { name: "x"; title: qsTr("<i>X</i> Variable"); allowedColumns: ["scale"]; singleVariable: true }
  		AssignedVariablesList { name: "y"; title: qsTr("<i>Y</i> Variable"); allowedColumns: ["scale"]; singleVariable: true }
  		AssignedVariablesList { name: "grouping_variable"; title: qsTr("Grouping variable"); allowedColumns: ["nominal"]; singleVariable: true }
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
      rowSpacing: 1
      columnSpacing: 1

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
          fieldWidth: jaspTheme.textFieldWidth
        }


        TextField
        {
          name: "comparison_level_name"
          id: comparison_level_name
          label: ""
          placeholderText: "Comparison level"
          enabled: from_summary.checked
          fieldWidth: jaspTheme.textFieldWidth
        }

        Label {
          text: qsTr("Correlation (<i>r</i>)")
        }

        DoubleField {
          name: "reference_r"
          label: ""
          defaultValue: 0.5
          min: -1
          max: 1
          fieldWidth: jaspTheme.textFieldWidth
          enabled: from_summary.checked
                  onEditingFinished : {
          summary_dirty.checked = true

        }
        }

        DoubleField {
          name: "comparison_r"
          label: ""
          defaultValue: 0.75
          min: -1
          max: 1
          fieldWidth: jaspTheme.textFieldWidth
          enabled: from_summary.checked
                  onEditingFinished : {
          summary_dirty.checked = true

        }
        }


        Label {
          text: qsTr("Sample size (<i>N</i>)")
        }

        DoubleField {
          name: "reference_n"
          label: ""
          defaultValue: 20
          min: 2
          fieldWidth: jaspTheme.textFieldWidth
          enabled: from_summary.checked
                  onEditingFinished : {
          summary_dirty.checked = true
        }
        }


        DoubleField {
          name: "comparison_n"
          label: ""
          defaultValue: 20
          min: 2
          fieldWidth: jaspTheme.textFieldWidth
          enabled: from_summary.checked
                  onEditingFinished : {
          summary_dirty.checked = true
        }
        }



        Label {
          text: qsTr("<i>X</i>-variable name")
        }

        TextField
        {
          name: "x_variable_name"
          id: x_variable_name
          placeholderText: "X variable"
          enabled: from_summary.checked
           Layout.columnSpan: 2
           fieldWidth: jaspTheme.textFieldWidth * 2
        }

        Label {
          text: qsTr("<i>Y</i>-variable name")
        }

        TextField
        {
          name: "y_variable_name"
          id: y_variable_name
          placeholderText: "Y variable"
          enabled: from_summary.checked
           Layout.columnSpan: 2
           fieldWidth: jaspTheme.textFieldWidth * 2
        }

        Label {
          text: qsTr("Grouping variable name")
        }


        TextField
        {
          name: "grouping_variable_name"
          id: grouping_variable_name
          placeholderText: "Grouping variable"
          enabled: from_summary.checked
           Layout.columnSpan: 2
           fieldWidth: jaspTheme.textFieldWidth * 2
        }
      } // end of 3 column grid



                        CheckBox
	    {
	      name: "summary_dirty";
	      id: summary_dirty
	      visible: false
	    }

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


    Section
  {
    title: qsTr("Scatterplot aesthetics")
    enabled: from_raw.checked
    visible: from_raw.checked


      GridLayout {
      id: grid
      columns: 4


      Label {
        text: " "
      }

      Label {
        text: qsTr("<u>Reference</u>")
      }


      Label {
        text: qsTr("<u>Comparison</u>")
      }


      Label {
        text: qsTr("<u>Unused</u>")
      }

      Label {
        text: qsTr("<b>Raw data</b>")
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Shape")
      }

      Esci.ShapeSelect
      {
        name: "sp_shape_raw_reference"
        id: sp_shape_raw_reference
        startValue: 'circle filled'
        enabled: from_raw.checked
      }

      Esci.ShapeSelect
      {
        name: "sp_shape_raw_comparison"
        id: sp_shape_raw_comparison
        startValue: 'circle filled'
        enabled: from_raw.checked
      }


      Esci.ShapeSelect
      {
        name: "shape_raw_unused"
        id: shape_raw_unused
        startValue: 'circle filled'
        enabled: from_raw.checked
      }


      Label {
        text: qsTr("Size")
      }

      Esci.SizeSelect
      {
        name: "sp_size_raw_reference"
        id: sp_size_raw_reference
        defaultValue: 3
        enabled: from_raw.checked

      }

      Esci.SizeSelect
      {
        name: "sp_size_raw_comparison"
        id: sp_size_raw_comparison
        defaultValue: 3
        enabled: from_raw.checked

      }

      Esci.SizeSelect
      {
        name: "sp_size_raw_unused"
        id: sp_size_raw_unused
        defaultValue: 2
        enabled: from_raw.checked

      }

      Label {
        text: qsTr("Outline")
      }

      Esci.ColorSelect
      {
        name: "sp_color_raw_reference"
        id: sp_color_raw_reference
        startValue: "black"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_color_raw_comparison"
        id: sp_color_raw_comparison
        startValue: "black"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_color_raw_unused"
        id: sp_color_raw_unused
        startValue: "black"
        enabled: from_raw.checked
      }


      Label {
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "sp_fill_raw_reference"
        id: sp_fill_raw_reference
        startValue: "#008DF9"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_fill_raw_comparison"
        id: sp_fill_raw_comparison
        startValue: "#009F81"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "sp_fill_raw_unused"
        id: sp_fill_raw_unused
        startValue: "NA"
        enabled: from_raw.checked
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_raw_reference"
        id: sp_alpha_raw_reference
        enabled: from_raw.checked
        defaultValue: 75

      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_raw_comparison"
        id: sp_alpha_raw_comparison
        enabled: from_raw.checked
        defaultValue: 75

      }

      Esci.AlphaSelect
      {
        name: "sp_alpha_raw_unused"
        id: sp_alpha_raw_unused
        enabled: from_raw.checked
        defaultValue: 75

      }


      Label {
        text: qsTr("<b>Regression lines</b>")
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Style")
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_summary_reference"
        id: sp_linetype_summary_reference
        enabled: show_line.checked
      }

      Esci.LineTypeSelect
      {
        name: "sp_linetype_summary_comparison"
        id: sp_linetype_summary_comparison
        enabled: show_line.checked
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Thickness")
      }

      IntegerField
      {
        name: "sp_size_summary_reference"
        defaultValue: 2
        min: 1
        max: 10
        enabled: show_line.checked
      }

      IntegerField
      {
        name: "sp_size_summary_comparison"
        defaultValue: 2
        min: 1
        max: 10
        enabled: show_line.checked
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Color")
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
        name: "sp_color_summary_comparison"
        id: sp_color_summary_comparison
        startValue: '#009F81'
        enabled: show_line.checked || show_line_CI.checked
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Transparency")
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
        name: "sp_alpha_summary_comparison"
        id: sp_alpha_summary_comparison
        enabled: show_line_CI.checked
        defaultValue: 75
      }

    } // end raw data


  } // end scatterplot aesthetics



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
        text: qsTr("<b>CI</b>")
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

  }


  Esci.HeOptions {
    id: myHeOptions
    null_value_enabled: false
    null_boundary_max: 1
  }


}
