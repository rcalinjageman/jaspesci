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

  function not_case_label_adjust() {
    not_case_label.text = "Not " + case_label.text
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
  		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); suggestedColumns: ["nominal"] }
  	}

  }


  Section {
    enabled: from_summary.checked
    visible: from_summary.checked
    expanded: from_summary.checked

    Group {

      TextField
      {
        name: "outcome_variable_name"
        label: qsTr("Outcome variable name")
        placeholderText: "Outcome variable"
      }

      GridLayout {
      id: sgrid
      columns: 2

        TextField
        {
          name: "case_label"
          id: case_label
          label: ""
          placeholderText: "Affected"
          onFocusChanged: {
            not_case_label_adjust()
          }
        }

        IntegerField
        {
          name: "cases"
          label: qsTr("Cases")
          defaultValue: 20
          min: 0
        }

        TextField
        {
          name: "not_case_label"
          id: not_case_label
          enabled: false
          label: ""
          placeholderText: "Not Affected"
        }

        IntegerField
        {
          name: "not_cases"
          label: qsTr("Sample size")
          defaultValue: 80
          min: 0
        }
      }  // 2 column grid
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
	    name: "plot_possible";
	    label: qsTr("Lines at proportion intervals");
	   }
	}


  Section
  {
    title: qsTr("Figure Options")


    GridLayout {
      id: fgrid
      columns: 3

      Label {
        text: qsTr("Dimensions")
      }

      IntegerField
      {
        name: "width"
        label: qsTr("Width")
        defaultValue: 300
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

      Label {
        text: qsTr("<i>Y</i> axis")
      }

      TextField
      {
        name: "ylab"
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

      Label {
        text: " "
      }

    TextField
      {
        name: "ymin"
        label: qsTr("Min")
        placeholderText: "0"
        fieldWidth: 60
      }

    TextField
      {
        name: "ymax"
        label: qsTr("Max")
        placeholderText: "1"
        fieldWidth: 60
      }

      Label {
        text: " "
      }

      TextField
      {
        name: "n.breaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
        fieldWidth: 60
      }

      Label {
        text: " "
      }

      Label {
        text: qsTr("<i>X</i> axis")
      }

      TextField
      {
        name: "xlab"
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


      Label {
        text: qsTr("Distributions")
      }

      DoubleField
      {
        name: "error_scale"
        label: qsTr("Width")
        defaultValue: 0.20
        min: 0
        max: 5
      }

      Label {
        text: " "
      }

      Label {
        text: " "
      }

    Esci.ErrorLayout
      {
        name: "error_layout"
        id: error_layout
      }

      Label {
        text: " "
      }

      Label {
        text: qsTr("Data")
      }

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
        defaultValue: 0.25
        enabled: from_raw.checked
        min: 0
        max: 5
      }

      Label {
        text: qsTr("Data")
      }


    DoubleField
      {
        name: "error_nudge"
        label: qsTr("Offset from CI")
        defaultValue: 0.3
        enabled: from_raw.checked
        min: 0
        max: 5
      }


    }


  Section
  {
    title: qsTr("Aesthetics")

    Group
    {
    title: qsTr("Summary")
    columns: 2
    Layout.columnSpan: 2

      Esci.ShapeSelect
      {
        label: qsTr("Shape")
        name: "shape_summary"
        id: shape_summary
      }

      Esci.SizeSelect
      {
        label: qsTr("Size")
        name: "size_summary"
      }

      Esci.ColorSelect
      {
        name: "color_summary"
        label: qsTr("Outline")
        startValue: '#008DF9'
        id: color_summary
      }


      Esci.ColorSelect
      {
        name: "fill_summary"
        label: qsTr("Fill")
        startValue: '#008DF9'
        id: fill_summary
      }


      Esci.AlphaSelect
      {
        label: qsTr("Transparency")
        name: "alpha_summary"
      }


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


    }


    Group
    {
    title: qsTr("Error distribution")
    columns: 2
    Layout.columnSpan: 2

      Esci.ColorSelect
      {
        name: "fill_error"
        label: qsTr("Fill")
        startValue: 'gray75'
        id: fill_error
      }

      Esci.AlphaSelect
      {
        name: "alpha_error"
        label: qsTr("Transparency")
      }


    }


    Group
    {
    title: qsTr("The raw data")
    columns: 2
    Layout.columnSpan: 2

      Esci.ShapeSelect
      {
        label: qsTr("Shape")
        name: "shape_raw"
        id: shape_raw
        enabled: from_raw.checked
      }

      Esci.SizeSelect
      {
        label: qsTr("Size")
        name: "size_raw"
        defaultValue: 2
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "color_raw"
        label: qsTr("Outline")
        startValue: '#008DF9'
        id: color_raw
        enabled: from_raw.checked
      }

      Esci.ColorSelect
      {
        name: "fill_raw"
        label: qsTr("Fill")
        startValue: 'NA'
        id: fill_raw
        enabled: from_raw.checked
      }

      Esci.AlphaSelect
      {
        name: "alpha_raw"
        enabled: from_raw.checked
        label: qsTr("Transparency")
      }


    }


  }

  }



	Section
  {
    title: qsTr("Hypothesis evaluation")

    Group
    {
      Layout.columnSpan: 2

      CheckBox
      {
      name: "evaluate_hypotheses"
      label: qsTr("Hypothesis evaluation")
      id: evaluate_hypotheses
      }

    }

    GridLayout {
      id: hgrid
      columns: 3

      DoubleField
      {
        name: "null_value"
        label: qsTr("Evaluate against <i>H</i><sub>0</sub> of: ")
        defaultValue: 0
        negativeValues: true
        enabled: evaluate_hypotheses.checked
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

      Label {
        text: "at alpha = .05"
        id: alpha_label
        enabled: evaluate_hypotheses.checked
        visible: evaluate_hypotheses.checked
      }

      Esci.ColorSelect
      {
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