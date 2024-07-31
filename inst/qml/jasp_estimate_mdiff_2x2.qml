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
    alpha_label.text = "At alpha = " + Number(1 - (conf_level.value/100)).toLocaleString(Qt.locale("de_DE"), 'f', 4)
  }

  function switch_adjust() {
      if (from_summary.checked) {
        effect_size.currentValue = "mean_difference";
      }
  }


  RadioButtonGroup {
    columns: 2
    Layout.columnSpan: 2
    name: "design"
    id: design

    RadioButton {
      value: "fully_between";
      label: qsTr("Fully between subjects");
      checked: true;
      id: fully_between
    }

    RadioButton {
      value: "mixed";
      label: qsTr("Mixed (RCT)");
      id: mixed
    }
  }  // end design selection


  RadioButtonGroup {
    columns: 2
    Layout.columnSpan: 2
    name: "switch"
    id: switch_source
    visible: fully_between.checked

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
  }  // end raw or summary


  Section {
    enabled: from_raw.checked & fully_between.checked
    visible: from_raw.checked & fully_between.checked
    expanded: from_raw.checked & fully_between.checked
    title: "Between subjects, full data"

    	VariablesForm
    	{
    		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
    		AvailableVariablesList { name: "allVariablesList_between" }
    		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); suggestedColumns: ["scale"]; singleVariable: true }
    		AssignedVariablesList { name: "grouping_variable_A"; title: qsTr("Grouping variable A"); suggestedColumns: ["nominal"]; singleVariable: true }
    		AssignedVariablesList { name: "grouping_variable_B"; title: qsTr("Grouping variable B"); suggestedColumns: ["nominal"]; singleVariable: true }

    	}

  }  // end between_raw


  Section {
    enabled: from_summary.checked & fully_between.checked
    visible: from_summary.checked & fully_between.checked
    expanded: from_summary.checked & fully_between.checked
    title: "Between subjects, summary data"

    GridLayout {
      id: summary_grid
      columns: 3

      Label {
        text: ""
      }

      TextField
      {
        name: "A_label"
        placeholderText: qsTr("Variable A")
        Layout.columnSpan: 2
      }

      Label {
        text: ""
      }

      TextField
      {
        name: "A1_label"
        placeholderText: qsTr("A1 level")
      }

      TextField
      {
        name: "A2_label"
        placeholderText: qsTr("A2 level")
      }


      TextField
      {
        name: "B_label"
        placeholderText: qsTr("Variable B")
        Layout.columnSpan: 1
      }

      Label {
        text: ""
      }

      Label {
        text: ""
      }

      Label {
        text: ""
      }


      DoubleField
      {
        name: "A1B1_mean"
        defaultValue: 10
        label: qsTr("<i>M</i>")
      }

      DoubleField
      {
        name: "A2B1_mean"
        defaultValue: 10
      }

      TextField
      {
        name: "B1_label"
        placeholderText: qsTr("B1 level")
      }


      DoubleField
      {
        name: "A1B1_sd"
        defaultValue: 2.1
        label: qsTr("<i>s</i>")
        negativeValues: false
      }

      DoubleField
      {
        name: "A2B1_sd"
        defaultValue: 2.2
        negativeValues: false
      }

      Label {
        text: ""
      }


      IntegerField
      {
        label: qsTr("<i>n</i>")
        name: "A1B1_n"
        defaultValue: 20
        min: 2
      }

      IntegerField
      {
        name: "A2B1_n"
        defaultValue: 20
        min: 2
      }


      Label {
        text: ""
      }

      DoubleField
      {
        name: "A1B2_mean"
        defaultValue: 15
        label: qsTr("<i>M</i>")
      }

      DoubleField
      {
        name: "A2B2_mean"
        defaultValue: 10
      }

      TextField
      {
        name: "B2_label"
        placeholderText: qsTr("B2 level")
      }


      DoubleField
      {
        name: "A1B2_sd"
        defaultValue: 2.3
        label: qsTr("<i>s</i>")
        negativeValues: false
      }

      DoubleField
      {
        name: "A2B2_sd"
        defaultValue: 2.4
        negativeValues: false
      }

      Label {
        text: ""
      }


      IntegerField
      {
        label: qsTr("<i>n</i>")
        name: "A1B2_n"
        defaultValue: 20
        negativeValues: false
      }

      IntegerField
      {
        name: "A2B2_n"
        defaultValue: 20
        negativeValues: false
      }


    }  // fully_between summary grid


    TextField
    {
        name: "outcome_variable_name_bs"
        label: qsTr("Outcome variable name")
        placeholderText: qsTr("My outcome variable")
        Layout.columnSpan: 2
    }


  }  // fully between summary section


    Section {
    enabled: mixed.checked
    visible: mixed.checked
    expanded: mixed.checked
    title: "RCT, full data"

    	VariablesForm
    	{
    		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
    		AvailableVariablesList { name: "allVariablesList" }
    		AssignedVariablesList { name: "outcome_variable_level1"; title: qsTr("First repeated measure"); suggestedColumns: ["scale"]; singleVariable: true }
    		AssignedVariablesList { name: "outcome_variable_level2"; title: qsTr("Second repeated measure"); suggestedColumns: ["scale"]; singleVariable: true }
    		AssignedVariablesList { name: "grouping_variable"; title: qsTr("Grouping variable"); suggestedColumns: ["nominal"]; singleVariable: true }
    	}


    	TextField
      {
        name: "repeated_measures_name"
        label: qsTr("Repeated measure name")
        placeholderText: qsTr("Time")
        Layout.columnSpan: 2
      }


    	TextField
      {
        name: "outcome_variable_name"
        label: qsTr("Outcome variable name")
        placeholderText: qsTr("My outcome variable")
        Layout.columnSpan: 2
      }


  } // mixed variable selection


	Group
	{
		title: qsTr("<b>Between-subjects analysis options</b>")
		Layout.columnSpan: 2
		visible: fully_between.checked

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
	  CheckBox
	  {
	    name: "show_interaction_plot";
	    label: qsTr("Figure to emphasize interaction");
	   }

	  CheckBox {
	    name: "show_CI";
	    id: show_CI
	    label: qsTr("CI for each simple effect")
    }
	}


  Esci.FigureOptions {
   simple_labels_enabled: true
   width_defaultValue: 700
   height_defaultValue: 400
   error_nudge_defaultValue: 0.5
   data_spread_defaultValue: 0.2
   error_scale_defaultValue: 0.25
  }


  Esci.AestheticsAll {

  }

	Esci.HeOptions {
    null_value_enabled: false
  }

}
