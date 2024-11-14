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
  		AssignedVariablesList { name: "reference_measure"; title: qsTr("Reference measure"); allowedColumns: ["nominal"]; singleVariable: true }
  		AssignedVariablesList { name: "comparison_measure"; title: qsTr("Comparison measure"); allowedColumns: ["nominal"]; singleVariable: true }
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
          text: " "
        }

        TextField {
          name: "comparison_measure_name"
          Layout.columnSpan: 2
          label: ""
          placeholderText: "Post-test"
          enabled: from_summary.checked
        }


        TextField {
          name: "reference_measure_name"
          label: ""
          placeholderText: "Pre-test"
          enabled: from_summary.checked
        }

        TextField
        {
          name: "case_label"
          id: case_label
          label: ""
          placeholderText: "Sick"
          enabled: from_summary.checked
        }


        TextField
        {
          name: "not_case_label"
          id: not_case_label
          label: ""
          placeholderText: "Well"
          enabled: from_summary.checked
        }

        Label {
          id: case_label_again
          text: "Sick"
          enabled: false
        }

        IntegerField
        {
          name: "cases_consistent"
          id: cases_consistent
          label: ""
          defaultValue: 18
          min: 0
        }

        IntegerField
        {
          name: "cases_inconsistent"
          id: cases_inconsistent
          label: ""
          defaultValue: 4
          min: 0
        }


        Label {
          id: not_case_label_again
          text: "Well"
          enabled: false
        }

        IntegerField
        {
          name: "not_cases_inconsistent"
          id: not_cases_inconsistent
          label: ""
          defaultValue: 12
          min: 0
        }

        IntegerField
        {
          name: "not_cases_consistent"
          id: not_cases_consistent
          label: ""
          defaultValue: 5
          min: 0
        }


      }  // 3 column grid
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


  Esci.FigureOptions {
    simple_labels_enabled: true
    simple_labels_visible: true
    difference_axis_grid_visible: true
    difference_axis_units_visible: false
    data_grid_visible: false
    distributions_grid_visible: false
    ymin_placeholderText: "auto"
    ymax_placeholderText: "auto"
    width_defaultValue: 400
    height_defaultValue: 450

        Section
  {
    title: qsTr("Aesthetics")

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
