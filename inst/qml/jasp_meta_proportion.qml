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


      	VariablesForm {
      	  height: 40
      		AvailableVariablesList {
      		  name: "allVariablesList"
      		}
      		AssignedVariablesList {
      		  name: "cases";
      		  id: cases
      		  label: qsTr("Case counts");
      		  suggestedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "ns";
      		  title: qsTr("Sample sizes");
      		  suggestedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "labels";
      		  title: qsTr("Study labels (optional");
      		  suggestedColumns: ["nominal"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "moderator";
      		  id: moderator;
      		  title: qsTr("Moderator (optional");
      		  suggestedColumns: ["nominal"];
      		  singleVariable: true
      		}
      	}


	Group {
		title: qsTr("<b>Analysis options</b>")
		columns: 1
		Layout.rowSpan: 1

		Esci.ConfLevel {
		    name: "conf_level"
		    id: conf_level
		}

    TextField {
        name: "effect_label"
        label: qsTr("Effect label")
        placeholderText: "My effect"
    }


    DropDown {
        name: "random_effects"
        label: qsTr("Model")
        startValue: 'random_effects'
        values:
          [
            { label: "Random effects (RE)", value: "random_effects"},
            { label: "Fixed effect (FE)", value: "fixed_effects"}
          ]
        id: random_effects
    }
	}

	Group {
	  title: qsTr("<b>Results options</b>")
		columns: 1
		Layout.columnSpan: 2

	  CheckBox {
	    name: "show_details";
	    id: show_details
	    label: qsTr("Extra details")
	  }

	  CheckBox {
	    name: "include_PIs";
	    label: qsTr("Prediction intervals")
	    enabled: random_effects.currentValue == "random_effects"
	  }


	}

  Esci.MetaFigureOptions {

  }


  Esci.MetaAesthetics {

  }

}
