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
        effect_size.currentValue = "mean"
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
      onClicked: {
         switch_adjust()
      }
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
  		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); allowedColumns: ["scale"] }
  	}

  }


  Section {
    enabled: from_summary.checked
    visible: from_summary.checked
    expanded: from_summary.checked

    Group {

      DoubleField
      {
        name: "mean"
        label: qsTr("Mean (<i>M</i>)")
        defaultValue: 10.1
      }

      DoubleField
      {
        name: "sd"
        label: qsTr("Standard deviation (<i>s</i>)")
        defaultValue: 3
        min: 0
      }

      IntegerField
      {
        name: "n"
        label: qsTr("Sample size (<i>N</i>)")
        defaultValue: 20
        min: 2
      }

      TextField
      {
        name: "outcome_variable_name"
        label: qsTr("Outcome variable name")
        placeholderText: "Outcome variable"
      }


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
        values:
          [
            { label: "Mean", value: "mean"},
            { label: "Median", value: "median"}
          ]
        id: effect_size
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
	    name: "show_calculations";
	    label: qsTr("Calculation components");
	    enabled: effect_size.currentValue == "mean"
	   }
	}


  Esci.FigureOptions {
    simple_labels_enabled: false
    simple_labels_visible: false
    difference_axis_grid_visible: false

        Section
  {
    title: qsTr("Aesthetics")


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

  } // end aesthetics


  }



  Esci.HeOptions {
    id: myHeOptions

  }

}
