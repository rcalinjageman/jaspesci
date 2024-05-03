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

	Formula { rhs: "variables" }

	VariablesForm
	{
		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
		AvailableVariablesList { name: "allVariablesList" }
		AssignedVariablesList { name: "variables"; title: qsTr("Outcome variable"); suggestedColumns: ["scale"] }
	}

	Group
	{
		title: qsTr(qsTr("Analysis options"))
		CIField
		  {
		    name: "ciLevel"
		    label: qsTr("Confidence level")
		  }
		DropDown
      {
        name: "effectSize"
        label: qsTr("Effect size of interest")
        values: ["Mean", "Median"]
      }
	}

	Group
	{
	  CheckBox { name: "extraDetails";	label: qsTr("Extra details") }
	  CheckBox { name: "calculationComponents";	label: qsTr("Calculation components") }
	}
}
