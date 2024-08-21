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
      		  name: "reference_cases";
      		  id: reference_cases
      		  label: qsTr("Case counts in reference group");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "reference_ns";
      		  title: qsTr("Sample sizes in reference group");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "comparison_cases";
      		  id: comparison_cases
      		  label: qsTr("Case counts in comparison group");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "comparison_ns";
      		  title: qsTr("Sample sizes in comparison group");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "labels";
      		  title: qsTr("Study labels (optional");
      		  allowedColumns: ["nominal"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "moderator";
      		  id: moderator;
      		  title: qsTr("Moderator (optional");
      		  allowedColumns: ["nominal"];
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
        name: "reported_effect_size"
        label: qsTr("Effect size")
        startValue: 'RD'
        values:
          [
            { label: "Risk difference (<i>P</i><sub>diff</sub>)", value: "RD"},
            { label: "Log risk ratio (ln(<i>RR</i>))", value: "RR"},
            { label: "Log odds ratio (ln(<i>OR</i>))", value: "AS"},
            { label: "Arcsine-square-root-transformed risk difference (1/2 * Cohen's H)", value: "AS"},
            { label: "Log odds ratio, Peto's method (ln(<i>OR</i>)<sub>Peto</sub>)", value: "PETO"}
          ]
        id: reported_effect_size
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
