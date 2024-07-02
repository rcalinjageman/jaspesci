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
        defaultValue: 600
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

      DoubleField
      {
        name: "meta_diamond_height"
        label: qsTr("Diamond height")
        defaultValue: 0.25
        min: 0
        max: 5
      }

  	  CheckBox {
  	    name: "report_CIs";
  	    label: qsTr("Include CIs")
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

      Label {
        text: " "
      }


       Label {
        text: qsTr("<i>X</i> axis")
      }

      TextField {
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


      IntegerField {
        name: "axis.text.x"
        label: qsTr("Tick Font Size")
        defaultValue: 14
        min: 2
        max: 80
    }

    IntegerField {
        name: "axis.title.x"
        label: qsTr("Label Font Size")
        defaultValue: 15
        min: 2
        max: 80
    }

     Label {
        text: " "
      }


    TextField {
        name: "xmin"
        label: qsTr("Min")
        placeholderText: "auto"
    }

    TextField {
        name: "xmax"
        label: qsTr("Max")
        placeholderText: "auto"
    }

     Label {
        text: " "
      }

      TextField {
        name: "xbreaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
      }

      CheckBox {
  	    name: "mark_zero";
  	    label: qsTr("Mark zero")
  	    checked: true
  	}

  	      Label {
        text: qsTr("Difference axis")
      }


      TextField {
        name: "dlab"
        label: qsTr("Label")
        placeholderText: "auto"
        enabled: moderator.count > 0
      }

           Label {
        text: " "
      }

           Label {
        text: " "
      }


    TextField {
        name: "dmin"
        label: qsTr("Min")
        placeholderText: "auto"
        enabled: moderator.count > 0
      }

      TextField {
        name: "dmax"
        label: qsTr("Max")
        placeholderText: "auto"
        enabled: moderator.count > 0
      }

      Label {
        text: " "
      }

       TextField {
        name: "dbreaks"
        label: qsTr("Num. tick marks")
        placeholderText: "auto"
        enabled: moderator.count > 0
      }

            Label {
        text: " "
      }

      Label {
        text: qsTr("Sample-size scaling")
      }

       DoubleField {
        name: "size_base"
        label: qsTr("Minimum")
        defaultValue: 2
        min: 0.25
        max: 8
      }

      DoubleField {
        name: "size_multiplier"
        label: qsTr("Multiplier")
        defaultValue: 3
        min: 1
        max: 5
      }


    }

    Section {
      title: qsTr("Aesthetics")

      GridLayout {
        id: grid
        columns: 5


        Label {
          text: " "
        }

        Label {
          text: "<b>Reference</b>"
        }


        Label {
          text: "<b>Comparison</b>"
        }


        Label {
          text: "<b>Difference</b>"
        }

        Label {
          text: "<b>Unused</b>"
        }

        Label {
          text: "<b>Point estimate markers</b>"
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: qsTr("Shape")
        }

        Esci.ShapeSelect
        {
          name: "shape_raw_reference"
          id: shape_raw_reference
          startValue: 'square filled'
        }

        Esci.ShapeSelect
        {
          name: "shape_raw_comparison"
          id: shape_raw_comparison
          startValue: 'square filled'
          enabled: moderator.count > 0
        }

        Esci.ShapeSelect
        {
          name: "shape_summary_difference"
          id: shape_summary_difference
          startValue: 'triangle filled'
          enabled: moderator.count > 0
        }

        Esci.ShapeSelect
        {
          name: "shape_raw_unused"
          id: shape_raw_unused
          startValue: 'square filled'
          enabled: moderator.count > 0
        }

        Label {
          text: qsTr("Outline")
        }

        Esci.ColorSelect
        {
          name: "color_raw_reference"
          id: color_raw_reference
          startValue: "#008DF9"
        }

        Esci.ColorSelect
        {
          name: "color_raw_comparison"
          id: color_raw_comparison
          startValue: "#009F81"
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "color_summary_difference"
          id: color_summary_difference
          startValue: 'black'
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "color_raw_unused"
          id: color_raw_unused
          startValue: 'gray65'
          enabled: moderator.count > 0
        }


        Label {
          text: qsTr("Fill")
        }

        Esci.ColorSelect
        {
          name: "fill_raw_reference"
          id: fill_raw_reference
          startValue: "#008DF9"
        }

        Esci.ColorSelect
        {
          name: "fill_raw_comparison"
          id: fill_raw_comparison
          startValue: "#009F81"
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "fill_summary_difference"
          id: fill_summary_difference
          startValue: 'black'
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "fill_raw_unused"
          id: fill_raw_unused
          startValue: 'gray65'
          enabled: moderator.count > 0
        }

        Label {
          text: qsTr("Transparency")
        }

        Esci.AlphaSelect
        {
          name: "alpha_raw_reference"
          id: alpha_raw_reference


        }

        Esci.AlphaSelect
        {
          name: "alpha_raw_comparison"
          id: alpha_raw_comparison
          enabled: moderator.count > 0

        }

        Esci.AlphaSelect
        {
          name: "alpha_summary_difference"
          id: alpha_summary_difference
          enabled: moderator.count > 0

        }

        Esci.AlphaSelect
        {
          name: "alpha_raw_unused"
          id: alpha_raw_unused
          enabled: moderator.count > 0

        }

        Label {
          text: qsTr("<b>CI</b>")
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: qsTr("Style")
        }

        Esci.LineTypeSelect
        {
          name: "linetype_raw_reference"
          id: linetype_raw_reference
        }

        Esci.LineTypeSelect
        {
          name: "linetype_raw_comparison"
          id: linetype_raw_comparison
          enabled: moderator.count > 0
        }

        Esci.LineTypeSelect
        {
          name: "linetype_summary_difference"
          id: linetype_summary_difference
          enabled: moderator.count > 0
        }


        Esci.LineTypeSelect
        {
          name: "linetype_raw_unused"
          id: linetype_raw_unused
          enabled: moderator.count > 0
        }

        Label {
          text: qsTr("Thickness")
        }

        DoubleField
        {
          name: "size_interval_reference"
          defaultValue: 0.50
          min: .25
          max: 10
        }

        DoubleField
        {
          name: "size_interval_comparison"
          defaultValue: 0.50
          min: .25
          max: 10
          enabled: moderator.count > 0
        }

        DoubleField
        {
          name: "size_interval_difference"
          defaultValue: 0.50
          min: .25
          max: 10
          enabled: moderator.count > 0
        }

        DoubleField
        {
          name: "size_interval_unused"
          defaultValue: 0.50
          min: .25
          max: 10
          enabled: moderator.count > 0
        }

        Label {
          text: qsTr("Color")
        }

        Esci.ColorSelect
        {
          name: "color_interval_reference"
          id: color_interval_reference
          startValue: 'black'
        }

        Esci.ColorSelect
        {
          name: "color_interval_comparison"
          id: color_interval_comparison
          startValue: 'black'
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "color_interval_difference"
          id: color_inteval_difference
          startValue: 'black'
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "color_interval_unused"
          id: color_inteval_unused
          startValue: 'black'
          enabled: moderator.count > 0
        }

        Label {
          text: qsTr("Transparency")
        }

        Esci.AlphaSelect
        {
          name: "alpha_interval_reference"
          id: alpha_interval_reference

        }

        Esci.AlphaSelect
        {
          name: "alpha_interval_comparison"
          id: alpha_interval_comparison
          enabled: moderator.count > 0

        }

        Esci.AlphaSelect
        {
          name: "alpha_interval_difference"
          id: alpha_interval_difference
          enabled: moderator.count > 0

        }

        Esci.AlphaSelect
        {
          name: "alpha_interval_unused"
          id: alpha_interval_unused
          enabled: moderator.count > 0

        }

        Label {
          text: "<b>Diamonds"
        }

        Label {
          text: " "
        }


        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: " "
        }

        Label {
          text: "Outline"
        }

        Label {
          text: "Fill"
        }

        Label {
          text: "Transparency"
        }

        Label {
          text: " "
        }

        Label {
          text: "Overall"
        }

        Esci.ColorSelect
        {
          name: "color_summary_overall"
          id: color_summary_overall
          startValue: 'black'
        }

        Esci.ColorSelect
        {
          name: "fill_summary_overall"
          id: fill_summary_overall
          startValue: 'black'
        }

        Esci.AlphaSelect
        {
          name: "alpha_summary_overall"
          id: alpha_summary_overall
        }

        Label {
          text: " "
        }

        Label {
          text: "Reference"
        }

        Esci.ColorSelect
        {
          name: "color_summary_reference"
          id: color_summary_reference
          startValue: '#008DF9'
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "fill_summary_reference"
          id: fill_summary_reference
          startValue: '#008DF9'
          enabled: moderator.count > 0
        }

        Esci.AlphaSelect
        {
          name: "alpha_summary_reference"
          id: alpha_summary_reference
          enabled: moderator.count > 0
        }

        Label {
          text: " "
        }

        Label {
          text: "Comparison"
        }

        Esci.ColorSelect
        {
          name: "color_summary_comparison"
          startValue: "#009F81"
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "fill_summary_comparison"
          startValue: "#009F81"
          enabled: moderator.count > 0
        }

        Esci.AlphaSelect
        {
          name: "alpha_summary_comparison"
          id: alpha_summary_comparison
          enabled: moderator.count > 0
        }

        Label {
          text: " "
        }

        Label {
          text: "Unused"
        }

        Esci.ColorSelect
        {
          name: "color_summary_unused"
          id: color_summary_unused
          startValue: 'gray75'
          enabled: moderator.count > 0
        }

        Esci.ColorSelect
        {
          name: "fill_summary_unused"
          id: fill_summary_unused
          startValue: 'gray75'
          enabled: moderator.count > 0
        }

        Esci.AlphaSelect
        {
          name: "alpha_summary_unused"
          id: alpha_summary_unused
          enabled: moderator.count > 0
        }

        Label {
          text: " "
        }

      }


    }



    }


}
