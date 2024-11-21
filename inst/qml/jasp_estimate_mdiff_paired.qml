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

	property alias sdiff_text: sdiff.text
	property alias conf_level_value: conf_level.value


	function alpha_adjust() {
	  myHeOptions.currentConfLevel = conf_level.value
  }

  function switch_adjust() {
      if (from_summary.checked) {
        effect_size.currentValue = "mean_difference";
        show_ratio.checked = false;
      }
  }

  function sdiff_adjust() {
      sdiff.value = ((sd1.value**2 + sd2.value**2 - 2*r.value*sd1.value*sd2.value)**0.5).toFixed(2);
  }

  function r_adjust() {
      r.value = ((sdiff.value**2 - sd1.value**2 - sd2.value**2)/(-2*sd1.value*sd2.value)).toFixed(2);
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
    		AssignedVariablesList { name: "reference_measure"; title: qsTr("Reference variable"); allowedColumns: ["scale"]; singleVariable: true }
    		AssignedVariablesList { name: "comparison_measure"; title: qsTr("Comparison variable"); allowedColumns: ["scale"]; singleVariable: true }
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
        name: "reference_measure_name"
        placeholderText: "Reference measure"
      }

      TextField
      {
        name: "comparison_measure_name"
        placeholderText: "Comparison measure"
      }

      Label {
        text: qsTr("Mean (<i>M</i>)")
      }

      DoubleField
      {
        name: "reference_mean"
        defaultValue: 10
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }

      DoubleField
      {
        name: "comparison_mean"
        defaultValue: 12
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }


      Label {
        text: qsTr("Standard deviation (<i>s</i>)")
      }

      DoubleField
      {
        name: "reference_sd"
        id: sd1
        defaultValue: 2.1
        min: 0
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }

      DoubleField
      {
        name: "comparison_sd"
        id: sd2
        defaultValue: 2.2
        min: 0
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }

      Label {
        text: qsTr("Sample size (<i>N</i>)")
      }

      IntegerField
      {
        name: "n"
        defaultValue: 20
        Layout.columnSpan: 2
        min: 2
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }

      RadioButtonGroup {
        Layout.columnSpan: 3
        columns: 2
        name: "enter_r_or_sdiff"
        id: enter_r_or_sdiff

        RadioButton {
          value: "enter_r";
          label: qsTr("Enter <i>r</i>");
          checked: true;
          id: enter_r
          onClicked: {
            sdiff_adjust()
          }
        }

        RadioButton {
          value: "enter_sdiff";
          id: enter_sdiff
          onClicked: {
            r_adjust()
          }
          Label {
            textFormat: Text.RichText
            text: qsTr("Enter standard deviation of difference scores (<i>s</i><sub>diff</sub>)")
            enabled: edter_sdiff.clicked
          }
        }
      }


      Label {
        text: qsTr("Correlation (<i>r</i>)")
      }

      DoubleField
      {
        name: "correlation"
        id: r
        Layout.columnSpan: 2
        enabled: enter_r.checked
        min: -1
        max: 1
        defaultValue: 0.7
          onFocusChanged: {
            sdiff_adjust()
          }
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }


      Label {
        textFormat: Text.RichText
        text: qsTr("Standard deviation of difference scores (<i>s</i><sub>diff</sub>)")
      }

      DoubleField
      {
        name: "sdiff"
        id: sdiff
        enabled: enter_sdiff.checked
        Layout.columnSpan: 2
        defaultValue: 1.67
          onFocusChanged: {
            r_adjust()
          }
        onEditingFinished : {
          summary_dirty.checked = true
        }
      }


    } // end first summary data grid

          CheckBox
	    {
	      name: "summary_dirty";
	      id: summary_dirty
	      visible: false
	    }

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

		DropDown
      {
        name: "effect_size"
        label: qsTr("Effect size of interest")
        enabled: from_raw.checked
        values:
          [
            { label: "Mean difference", value: "mean_difference"},
            { label: "Median difference", value: "median_difference"}
          ]
        id: effect_size
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
	  CheckBox
	  {
	    name: "show_calculations";
	    label: qsTr("Calculation components");
	    enabled: effect_size.currentValue == "mean_difference"
	   }
	  CheckBox {
	    name: "show_ratio";
	    id: show_ratio
	    label: qsTr("Ratio between groups (appropriate only for true ratio scales")
	    enabled: from_raw.checked
    }
	}


  Esci.FigureOptions {
    width_defaultValue: 600
    height_defaultValue: 400
    error_nudge_defaultValue: 0.5
    data_spread_defaultValue: 0.2
    error_scale_defaultValue: 0.25


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
        text: "<u>Reference</u>"
      }


      Label {
        text: "<u>Comparison</u>"
      }


      Label {
        text: "<u>Difference</u>"
      }


      Label {
        text: "<b>Summary</b>"
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
        startValue: "#008DF9"
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
        startValue: "#008DF9"
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
        text: qsTr("<b>CI</b>")
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
        enabled: effect_size.currentValue == "mean_difference"
      }

      IntegerField
      {
        name: "size_interval_comparison"
        defaultValue: 3
        min: 1
        max: 10
        enabled: effect_size.currentValue == "mean_difference"
      }

      IntegerField
      {
        name: "size_interval_difference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: qsTr("Color")
      }

      Esci.ColorSelect
      {
        name: "color_interval_reference"
        id: color_interval_reference
        startValue: 'black'
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "color_interval_comparison"
        id: color_interval_comparison
        startValue: 'black'
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "color_interval_difference"
        id: color_inteval_difference
        startValue: 'black'
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_reference"
        id: alpha_interval_reference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_comparison"
        id: alpha_interval_comparison
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_difference"
        id: alpha_interval_difference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Label {
        text: qsTr("<b>Error distribution</b>")
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
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "fill_error_comparison"
        id: fill_error_comparison
        startValue: "gray75"
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "fill_error_difference"
        id: fill_error_difference
        startValue: 'gray75'
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_error_reference"
        id: alpha_error_reference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_comparison"
        id: alpha_error_comparison
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_difference"
        id: alpha_error_difference
        enabled: effect_size.currentValue == "mean_difference"

      }


      Label {
        text: "<b>Raw data</b>"
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

      Esci.ShapeSelect
      {
        name: "shape_raw_difference"
        id: shape_raw_difference
        startValue: 'triangle filled'
        enabled: from_raw.checked
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

      Esci.SizeSelect
      {
        name: "size_raw_difference"
        id: size_raw_difference
        defaultValue: 2
        enabled: from_raw.checked

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
        startValue: "#008DF9"
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "color_raw_difference"
        id: color_raw_difference
        startValue: "#E20134"
        enabled: from_raw.checked
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

      Esci.ColorSelect
      {
        name: "fill_raw_difference"
        id: fill_raw_difference
        startValue: "NA"
        enabled: from_raw.checked
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

      Esci.AlphaSelect
      {
        name: "alpha_raw_difference"
        id: alpha_raw_difference
        enabled: from_raw.checked

      }


    } // end aesthetics group


  } // end aesthetics


  }

	Esci.HeOptions {
    id: myHeOptions
    null_value_enabled: false
    hgrid_columns: 4
    rope_units_visible: evaluate_hypotheses_checked
  }

}
