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
		CIField
		  {
		    name: "conf_level"
		    label: qsTr("Confidence level")
		    id: conf_level
		    min: 75
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
	  CheckBox
	  {
	    name: "extraDetails";
	    label: qsTr("Extra details")
	   }
	  CheckBox
	  {
	    name: "calculationComponents";
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
    TextField
      {
        name: "ylab"
        label: qsTr("Label")
        placeholderText: "auto"
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
        name: "y.breaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
      }
    }

    Group
    {
    title: qsTr("<i>X</i> axis")
    TextField
      {
        name: "xlab"
        label: qsTr("Label")
        placeholderText: "auto"
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
    DoubleField
      {
        name: "error_scale"
        label: qsTr("Label")
        defaultValue: 0.20
        min: 0
        max: 5
      }


    DropDown
      {
        name: "error_layout"
        label: qsTr("Style")
        values:
          [
            { label: "Plausibility curve", value: "halfeye"},
            { label: "Cat's eye", value: "eye"},
            { label: "None", value: "none"}
          ]
        id: error_layout
      }

    }

    Group
    {
    title: qsTr("Data")

    DropDown
      {
        name: "data_layout"
        label: qsTr("Layout")
        values:
          [
            { label: "Random", value: "random"},
            { label: "Swarm", value: "swarm"},
            { label: "None", value: "none"}
          ]
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

      DropDown
      {
        name: "shape_summary"
        label: qsTr("Shape")
        values:
          [
            { label: "Circle", value: "circle filled"},
            { label: "Square", value: "square filled"},
            { label: "Diamond", value: "diamond filled"},
            { label: "Triangle", value: "triangle filled"}
          ]
        id: summary_shape
      }

      IntegerField
      {
        name: "size_summary"
        label: qsTr("Size")
        defaultValue: 4
        min: 1
        max: 6
      }



      Rectangle {
        id: color_summary
        color: "steelblue"
        width: 40; height: 40

        MouseArea {
          anchors.fill: parent
          onClicked: { colorDialog.open() }
        }

        ColorDialog {
          id: colorDialog
          selectedColor: color_summary.color
          onAccepted: color_summary.color = selectedColor
        }


      }








    }
  }


  }

	Section
  {
    title: qsTr("Hypothesis evaluation")

    CheckBox
    {
    name: "hypothesis_evaluation"
    label: qsTr("Hypothesis evaluation")
    id: hypothesis_evaluation
    }

    Group
    {
      DoubleField
      {
        name: "reference_mean"
        label: qsTr("Evaluate against <i>H</i><sub>0</sub> of: ")
        defaultValue: 0
        enabled: hypothesis_evaluation.checked
        visible: hypothesis_evaluation.checked
      }

      DoubleField
      {
        name: "rope"
        label: qsTr("+/- ")
        defaultValue: 0
        negativeValues: false
        enabled: hypothesis_evaluation.checked
        visible: hypothesis_evaluation.checked
        afterLabel: "alpha: " + conf_level.currentValue
      }


    }
  }

}
