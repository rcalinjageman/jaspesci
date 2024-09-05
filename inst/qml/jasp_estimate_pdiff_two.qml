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
  		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); allowedColumns: ["nominal"] }
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

        Label {
          text: " "
        }


        TextField {
          name: "grouping_variable_name"
          Layout.columnSpan: 2
          label: ""
          placeholderText: "Grouping variable"
        }


        TextField {
          name: "outcome_variable_name"
          label: ""
          placeholderText: "Outcome variable"
        }

        TextField {
          name: "grouping_variable_level1"
          label: ""
          placeholderText: "Control"
        }

        TextField {
          name: "grouping_variable_level2"
          label: ""
          placeholderText: "Treated"
        }


        TextField
        {
          name: "case_label"
          id: case_label
          label: ""
          placeholderText: "Sick"
        }

        IntegerField
        {
          name: "reference_cases"
          id: reference_cases
          label: ""
          defaultValue: 20
          min: 0
        }

        IntegerField
        {
          name: "comparison_cases"
          id: comparison_cases
          label: ""
          defaultValue: 40
          min: 0
        }

        TextField
        {
          name: "not_case_label"
          id: not_case_label
          label: ""
          placeholderText: "Well"
        }

        IntegerField
        {
          name: "reference_not_cases"
          id: reference_not_cases
          label: ""
          defaultValue: 80
          min: 0
        }

        IntegerField
        {
          name: "comparison_not_cases"
          id: comparison_not_cases
          label: ""
          defaultValue: 60
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

		CheckBox
	  {
	    name: "count_NA";
	    label: qsTr("Missing cases are counted")
	    enabled: from_raw.checked
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
	    name: "show_ratio";
	    label: qsTr("Odds ratio");
	   }
	  CheckBox
	  {
	    name: "show_phi";
	    label: qsTr("Correlation (\u03D5)");
	   }


      GridLayout {
      id: show_chi_square_grid
      columns: 4
    	 	CheckBox
    	  {
    	    name: "show_chi_square";
    	    id: show_chi_square;
    	    label: qsTr("&#120536;<sup>2</sup> analysis");
    	  }


        RadioButtonGroup {
          columns: 3
          name: "chi_table_option"
          id: chi_table_option

          RadioButton {
            value: "observed";
            label: qsTr("Observed frequencies");
            id: observed
            enabled: show_chi_square.checked
          }

          RadioButton {
            value: "expected";
            label: qsTr("Expected frequencies");
            id: expected
            enabled: show_chi_square.checked
          }

          RadioButton {
            value: "both";
            label: qsTr("Both");
            id: both;
            checked: true;
            enabled: show_chi_square.checked
          }
      } // end chi_table_option

    } // end show_chi_square 4-column grid

}


  Esci.FigureOptions {
    simple_labels_enabled: false
    simple_labels_visible: false
    difference_axis_grid_visible: true
    difference_axis_units_visible: false
    data_grid_visible: false
    distributions_grid_visible: false
    ymin_placeholderText: "auto"
    ymax_placeholderText: "auto"

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

  }



  Esci.HeOptions {
    id: myHeOptions
    null_value_enabled: false
    null_boundary_max: 1
  }


}
