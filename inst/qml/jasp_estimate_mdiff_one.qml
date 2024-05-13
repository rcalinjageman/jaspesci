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

	VariablesForm
	{
		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
		AvailableVariablesList { name: "allVariablesList" }
		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); suggestedColumns: ["scale"] }
	}


	Group
	{
		title: qsTr("<b>Analysis options</b>")
		columns: 2
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
        values:
          [
            { label: "Mean", value: "mean"},
            { label: "Median", value: "median"}
          ]
        id: effect_size
      }
	}

	Group
	{
	  title: qsTr("<b>Results options</b>")
		columns: 2
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
	    enabled: effect_size.currentValue == "mean"
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
        name: "n.breaks"
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
        defaultValue: 0.20
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
      }


    DoubleField
      {
        name: "data_spread"
        label: qsTr("Layout")
        defaultValue: 0.25
        min: 0
        max: 5
      }

    DoubleField
      {
        name: "error_nudge"
        label: qsTr("Offset from CI")
        defaultValue: 0.3
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
      }

      Esci.SizeSelect
      {
        label: qsTr("Size")
        name: "size_raw"
        defaultValue: 2
      }

      Esci.ColorSelect
      {
        name: "color_raw"
        label: qsTr("Outline")
        startValue: '#008DF9'
        id: color_raw
      }

      Esci.ColorSelect
      {
        name: "fill_raw"
        label: qsTr("Fill")
        startValue: 'NA'
        id: fill_raw
      }

      Esci.AlphaSelect
      {
        name: "alpha_raw"
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
      columns: 2
      Layout.columnSpan: 2

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
        afterLabel: "alpha: " + conf_level.currentValue
      }


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
