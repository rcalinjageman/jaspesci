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
