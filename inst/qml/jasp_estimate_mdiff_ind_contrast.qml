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


	function alpha_adjust() {
	  myHeOptions.currentConfLevel = conf_level.value
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
    		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable(s)"); suggestedColumns: ["scale"] }
    		AssignedVariablesList { name: "grouping_variable"; title: qsTr("Grouping variable"); suggestedColumns: ["nominal"]; singleVariable: true }
    	}

  }


  Section {
    enabled: from_summary.checked
    visible: from_summary.checked
    expanded: from_summary.checked


    VariablesForm {
      preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
      AvailableVariablesList { name: "allVariablesList_summary" }
      AssignedVariablesList { name: "grouping_variable_levels"; title: qsTr("Grouping variable levels"); suggestedColumns: ["nominal"]; singleVariable: true }
      AssignedVariablesList { name: "means"; title: qsTr("Group means"); suggestedColumns: ["scale"]; singleVariable: true }
      AssignedVariablesList { name: "sds"; title: qsTr("Group standard deviations"); suggestedColumns: ["scale"]; singleVariable: true }
      AssignedVariablesList { name: "ns"; title: qsTr("Group samplpe sizes"); suggestedColumns: ["scale"]; singleVariable: true }
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

  Group {
    title: qsTr("<b>Define contrast</b>")
    Layout.columnSpan: 2

     TextField
      {
        name: "reference_labels"
        id: reference_labels
        label: qsTr("Reference subset")
      }

     TextField
      {
        name: "comparison_labels"
        id: comparison_labels
        label: qsTr("Comparison subset")
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
	  CheckBox
	  {
	    name: "show_details";
	    label: qsTr("Extra details")
	   }

	  CheckBox
	  {
	    name: "mixed";
	    id: mixed
	    visible: false
	    enabled: false
	   }
	}


  Esci.FigureOptions {
   simple_labels_enabled: true
   width_defaultValue: 550
   height_defaultValue: 450
   error_nudge_defaultValue: 0.5
   data_spread_defaultValue: 0.20
   error_scale_defaultValue: 0.25


    Esci.AestheticsAll {

    }
  }




	Esci.HeOptions {
	  id: myHeOptions
    null_value_enabled: false
    rope_units_visible: evaluate_hypotheses_checked
    hgrid_columns: 4
  }

}
