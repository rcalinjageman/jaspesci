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
import QtQuick.Dialogs
import JASP
import JASP.Controls
import "./esci" as Esci

Form
{
	id: form
	property int framework:	Common.Type.Framework.Classical


	function alpha_adjust() {
    alpha_label.text = "At alpha = " + Number(1 - (conf_level.value/100)).toLocaleString(Qt.locale("de_DE"), 'f', 4)
  }

  function switch_adjust() {
      if (from_summary.checked) {
        effect_size.currentValue = "mean_difference";
        show_ratio.checked = false;
      }
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
      onClicked: {
         switch_adjust()
      }
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
    		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); suggestedColumns: ["scale"] }
    		AssignedVariablesList { name: "grouping_variable"; title: qsTr("Grouping variable"); suggestedColumns: ["nominal"]; singleVariable: true }
    	}

      Group {
      	columns: 2
    		Layout.columnSpan: 2

      	CheckBox {
      	  name: "switch_comparison_order";
      	  label: qsTr("Switch comparison order")
        }
      }
  }


  Section {
    enabled: from_summary.checked
    visible: from_summary.checked
    expanded: from_summary.checked

    GridLayout {
      id: summary_grid
      columns: 3

      Label {
        text: ""
      }

      Label {
        text: "Reference group"
      }

      Label {
        text: "Comparison group"
      }


      Label {
        text: qsTr("Name")
      }

      TextField
      {
        name: "reference_level_name"
        placeholderText: "Reference group"
      }

      TextField
      {
        name: "comparison_level_name"
        placeholderText: "Comparison group"
      }

      Label {
        text: qsTr("Mean (<i>M</i>)")
      }

      DoubleField
      {
        name: "reference_mean"
        defaultValue: 10
      }

      DoubleField
      {
        name: "comparison_mean"
        defaultValue: 12
      }


      Label {
        text: qsTr("Standard deviation (<i>s</i>)")
      }

      DoubleField
      {
        name: "reference_sd"
        defaultValue: 3
        min: 0
      }

      DoubleField
      {
        name: "comparison_sd"
        defaultValue: 3
        min: 0
      }


      Label {
        text: qsTr("Sample size (<i>n</i>)")
      }

      IntegerField
      {
        name: "reference_n"
        defaultValue: 20
        min: 2
      }

      IntegerField
      {
        name: "comparison_n"
        defaultValue: 20
        min: 2
      }

    }


    Group {
      Layout.columnSpan: 2
      TextField
      {
        name: "outcome_variable_name"
        label: qsTr("Outcome variable name")
        placeholderText: "Outcome variable"
      }


      TextField
      {
        name: "grouping_variable_name"
        label: qsTr("Grouping variable name")
        placeholderText: "Grouping variable"
      }

    }


  }

	Group
	{
		title: qsTr("<b>Analysis options</b>")
		columns: 1
		Layout.columnSpan: 2

		Esci.ConfLevel
		  {
		    name: "conf_level"
		    id: conf_level
		  }

		DropDown
      {
        name: "effect_size"
        label: qsTr("Effect size of interest")
        enabled: from_raw.checked
        values:
          [
            { label: "Mean diiference", value: "mean_difference"},
            { label: "Median difference", value: "median_difference"}
          ]
        id: effect_size
      }

    CheckBox {
	    name: "assume_equal_variance";
	    id: assume_equal_variance
	    label: qsTr("Assume equal variance")
	    checked: true
	    enabled: effect_size.currentValue == "mean_difference"
    }

	}

	Group
	{
	  title: qsTr("<b>Results options</b>")
		columns: 1
		Layout.columnSpan: 2
	  CheckBox
	  {
	    name: "show_details";
	    label: qsTr("Extra details")
	   }
	  CheckBox
	  {
	    name: "show_calculations";
	    label: qsTr("Calculation components");
	    enabled: effect_size.currentValue == "mean_difference" & assume_equal_variance.checked
	   }
	  CheckBox {
	    name: "show_ratio";
	    id: show_ratio
	    label: qsTr("Ratio between groups (appropriate only for true ratio scales")
	    enabled: from_raw.checked
    }
	}

  Section
  {
    title: qsTr("Figure Options")
    Group
    {
    title: qsTr("Dimensions")
    columns: 2
    Layout.columnSpan: 2
    IntegerField
      {
        name: "width"
        label: qsTr("Width")
        defaultValue: 600
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

    }


    Group
    {
    title: qsTr("<i>Y</i> axis")
    columns: 2
    Layout.columnSpan: 2

    Group
    {
      Layout.columnSpan: 2
      TextField
      {
        name: "ylab"
        label: qsTr("Label")
        placeholderText: "auto"
      }
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

    TextField
      {
        name: "ymin"
        label: qsTr("Min")
        placeholderText: "auto"
      }

    TextField
      {
        name: "ymax"
        label: qsTr("Max")
        placeholderText: "auto"
      }

    TextField
      {
        name: "ybreaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
      }
    }

    Group
    {
    title: qsTr("<i>X</i> axis")
    columns: 2
    Layout.columnSpan: 2

    Group {
      Layout.columnSpan: 2

      TextField
      {
        name: "xlab"
        label: qsTr("Label")
        placeholderText: "auto"
      }
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

      CheckBox {
	      name: "simple_contrast_labels";
	      label: qsTr("Simple labels")
	      checked: true
      }
    }


    Group
    {
    title: qsTr("Difference axis")
    columns: 2
    Layout.columnSpan: 2

    Group {
      Layout.columnSpan: 2

      DropDown
      {
        name: "difference_axis_units"
        label: qsTr("Units")
        startValue: 'raw'
        values:
          [
            { label: "Original units", value: "raw"},
            { label: "Standard deviations", value: "sd"}
          ]
      }
    }

    TextField
      {
        name: "difference_axis_breaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
      }

    }


    Group
    {
    title: qsTr("Distributions")
    columns: 2
    Layout.columnSpan: 2

    DoubleField
      {
        name: "error_scale"
        label: qsTr("Width")
        defaultValue: 0.25
        min: 0
        max: 5
      }


    Esci.ErrorLayout
      {
        name: "error_layout"
        id: error_layout
      }

    }

    Group
    {
    title: qsTr("Data")
    columns: 2
    Layout.columnSpan: 2

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
        enabled: from_raw.checked
        defaultValue: 0.20
        min: 0
        max: 5
      }

    DoubleField
      {
        name: "error_nudge"
        label: qsTr("Offset from CI")
        enabled: from_raw.checked
        defaultValue: 0.5
        min: 0
        max: 5
      }


    }


  Section
  {
    title: qsTr("Aesthetics")

    GridLayout {
      id: grid
      columns: 4


      Label {
        text: " "
      }

      Label {
        text: "Reference"
      }


      Label {
        text: "Comparison"
      }


      Label {
        text: "Difference"
      }


      Label {
        text: "Summary"
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
        name: "shape_summary_reference"
        id: shape_summary_reference
        startValue: 'circle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_comparison"
        id: shape_summary_comparison
        startValue: 'circle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_difference"
        id: shape_summary_difference
        startValue: 'triangle filled'
      }


      Label {
        text: qsTr("Size")
      }

      Esci.SizeSelect
      {
        name: "size_summary_reference"
        id: size_summary_reference

      }

      Esci.SizeSelect
      {
        name: "size_summary_comparison"
        id: size_summary_comparison

      }

      Esci.SizeSelect
      {
        name: "size_summary_difference"
        id: size_summary_difference

      }

      Label {
        text: qsTr("Outline")
      }

      Esci.ColorSelect
      {
        name: "color_summary_reference"
        id: color_summary_reference
        startValue: "#008DF9"
      }

      Esci.ColorSelect
      {
        name: "color_summary_comparison"
        id: color_summary_comparison
        startValue: "#009F81"
      }

      Esci.ColorSelect
      {
        name: "color_summary_difference"
        id: color_summary_difference
        startValue: 'black'
      }

      Label {
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_summary_reference"
        id: fill_summary_reference
        startValue: "#008DF9"
      }

      Esci.ColorSelect
      {
        name: "fill_summary_comparison"
        id: fill_summary_comparison
        startValue: "#009F81"
      }

      Esci.ColorSelect
      {
        name: "fill_summary_difference"
        id: fill_summary_difference
        startValue: 'black'
      }

      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_reference"
        id: alpha_summary_reference

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_comparison"
        id: alpha_summary_comparison

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_difference"
        id: alpha_summary_difference

      }

      Label {
        text: qsTr("CI")
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


      Label {
        text: qsTr("Thickness")
      }

      IntegerField
      {
        name: "size_interval_reference"
        defaultValue: 3
        min: 1
        max: 10
      }

      IntegerField
      {
        name: "size_interval_comparison"
        defaultValue: 3
        min: 1
        max: 10
      }

      IntegerField
      {
        name: "size_interval_difference"
        defaultValue: 3
        min: 1
        max: 10
      }


      Label {
        text: qsTr("Color")
      }

      Esci.ColorSelect
      {
        name: "color_interval_reference"
        id: color_interval_reference
        startValue: 'black'
      }

      Esci.ColorSelect
      {
        name: "color_interval_comparison"
        id: color_interval_comparison
        startValue: 'black'
      }

      Esci.ColorSelect
      {
        name: "color_interval_difference"
        id: color_inteval_difference
        startValue: 'black'
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_reference"
        id: alpha_interval_reference

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_comparison"
        id: alpha_interval_comparison

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_difference"
        id: alpha_interval_difference

      }

      Label {
        text: qsTr("Error distribution")
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
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_error_reference"
        id: fill_error_reference
        startValue: "gray75"
      }

      Esci.ColorSelect
      {
        name: "fill_error_comparison"
        id: fill_error_comparison
        startValue: "gray75"
      }

      Esci.ColorSelect
      {
        name: "fill_error_difference"
        id: fill_error_difference
        startValue: 'gray75'
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_error_reference"
        id: alpha_error_reference

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_comparison"
        id: alpha_error_comparison

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_difference"
        id: alpha_error_difference

      }


      Label {
        text: "Raw data"
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
        name: "shape_raw_reference"
        id: shape_raw_reference
        startValue: 'circle filled'
        enabled: from_raw.checked
      }

      Esci.ShapeSelect
      {
        name: "shape_raw_comparison"
        id: shape_raw_comparison
        startValue: 'circle filled'
        enabled: from_raw.checked
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Size")
      }

      Esci.SizeSelect
      {
        name: "size_raw_reference"
        id: size_raw_reference
        defaultValue: 2
        enabled: from_raw.checked

      }

      Esci.SizeSelect
      {
        name: "size_raw_comparison"
        id: size_raw_comparison
        defaultValue: 2
        enabled: from_raw.checked

      }

      Label {
        text: " "
      }

      Label {
        text: qsTr("Outline")
      }

      Esci.ColorSelect
      {
        name: "color_raw_reference"
        id: color_raw_reference
        startValue: "#008DF9"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "color_raw_comparison"
        id: color_raw_comparison
        startValue: "#009F81"
        enabled: from_raw.checked
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_raw_reference"
        id: fill_raw_reference
        startValue: "NA"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "fill_raw_comparison"
        id: fill_raw_comparison
        startValue: "NA"
        enabled: from_raw.checked
      }

      Label {
        text: " "
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_raw_reference"
        id: alpha_raw_reference
        enabled: from_raw.checked

      }

      Esci.AlphaSelect
      {
        name: "alpha_raw_comparison"
        id: alpha_raw_comparison
        enabled: from_raw.checked

      }

      Label {
        text: " "
      }




    }


  }

  }



	Section
  {
    title: qsTr("Hypothesis evaluation")

    Group
    {
      columns: 2
      Layout.columnSpan: 2

      CheckBox
      {
      name: "evaluate_hypotheses"
      label: qsTr("Hypothesis evaluation")
      id: evaluate_hypotheses
      }

    }

    Group
    {
      columns: 4
      Layout.rowSpan: 2

      DoubleField
      {
        name: "null_value"
        label: qsTr("Evaluate against <i>H</i><sub>0</sub> of: ")
        defaultValue: 0
        negativeValues: true
        enabled: false
        visible: evaluate_hypotheses.checked
      }

      DoubleField
      {
        name: "null_boundary"
        label: qsTr("+/- ")
        defaultValue: 0
        negativeValues: false
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
      }


      DropDown {
        name: "rope_units"
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
        values: [
            { label: "Original units", value: "raw"},
            { label: "Standard deviations", value: "sd"}
          ]
        id: rope_units
      }


      Label {
        text: "alpha"
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
      }

    }


    Group {
      columns: 2
      Layout.columnSpan: 2

      Esci.ColorSelect {
        name: "null_color"
        label: qsTr("Color for null hypothesis")
        startValue: '#A40122'
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
        id: null_color
      }

    }

  }

}
