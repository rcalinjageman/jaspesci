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

	function dlab() {
    if (from_raw.checked) {
      reference_means.label = "Reference means (<i>M</i><sub>reference</sub>)"
    } else {
      reference_means.label = "Standardized mean differences, bias corrected"
    }
  }


  RadioButtonGroup {
    columns: 2
    name: "switch"
    id: switch_source

    RadioButton {
      value: "from_raw";
      label: qsTr("Analyze original units");
      checked: true;
      id: from_raw
      onClicked: {
         dlab()
      }
    }

    RadioButton {
      value: "from_d";
      label: qsTr("Analyze Cohen's <i>d</i>");
      id: from_d
      onClicked: {
         dlab()
      }
    }
  }

      	VariablesForm {
      	  height: 200
      		AvailableVariablesList {
      		  name: "allVariablesList"
      		}

      		AssignedVariablesList {
      		  name: "reference_means";
      		  id: reference_means
      		  label: qsTr("Reference means (<i>M</i><sub>reference</sub>)");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "reference_sds";
      		  title: qsTr("Reference standard deviations (<i>s</i><sub>reference</sub>)");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		  enabled: from_raw.checked
      		  visible: from_raw.checked
      		}
      		AssignedVariablesList {
      		  name: "reference_ns";
      		  title: qsTr("Reference sample sizes (<i>N</i><sub>reference</sub>)");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "comparison_means";
      		  id: comparison_means
      		  label: qsTr("Comparison means (<i>M</i><sub>comparison</sub>)");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		  enabled: from_raw.checked
      		  visible: from_raw.checked
      		}
      		AssignedVariablesList {
      		  name: "comparison_sds";
      		  title: qsTr("Comparison standard deviations (<i>s</i><sub>comparison</sub>)");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		  enabled: from_raw.checked
      		  visible: from_raw.checked
      		}
      		AssignedVariablesList {
      		  name: "comparison_ns";
      		  title: qsTr("Comparison sample sizes (<i>N</i><sub>comparison</sub>)");
      		  allowedColumns: ["scale"];
      		  singleVariable: true
      		}
      		AssignedVariablesList {
      		  name: "r";
      		  title: qsTr("<i>r</i> (Optional; leave blank for between-subjects)");
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


  Label {
        text: qsTr(" ")
      }

  Label {
        text: qsTr(" ")
      }

  Label {
        text: qsTr(" ")
      }

  Label {
        text: qsTr(" ")
      }

  Label {
        text: qsTr(" ")
      }

  Label {
        text: qsTr(" ")
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
        startValue: 'mean_difference'
        enabled: from_raw.checked
        values:
          [
            { label: "Original units", value: "mean_difference"},
            { label: "Standardized mean difference", value: "smd_unbiased"}
          ]
        id: effect_size
    }

    CheckBox {
	    name: "assume_equal_variance";
	    id: assume_equal_variance
	    checked: true;
	    label: qsTr("Assume equal variances")
	  }

    DropDown {
        name: "random_effects"
        label: qsTr("Model")
        startValue: 'random_effects'
        values:
          [
            { label: "Random effects (RE)", value: "random_effects"},
            { label: "Fixed effect (FE)", value: "fixed_effects"},
            { label: "Compare fixed and random effects", value: "compare"}
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
