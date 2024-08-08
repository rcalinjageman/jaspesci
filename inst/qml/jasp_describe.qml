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

  VariablesForm
  	{
  		preferredHeight: jaspTheme.smallDefaultVariablesFormHeight
  		AvailableVariablesList { name: "allVariablesList" }
  		AssignedVariablesList { name: "outcome_variable"; title: qsTr("Outcome variable"); suggestedColumns: ["scale"]; singleVariable: true}
  	}

	Group
	{
	  title: qsTr("<b>Results options</b>")
	  Layout.columnSpan: 2

	  CheckBox
	  {
	    name: "show_details";
	    label: qsTr("Extra details")
	   }
	}

	Group
	{
	  title: qsTr("<b>Explore</b>")


	   GridLayout {
      id: explore_grid
      columns: 3


      Label {
        text: qsTr("Location")
      }

      CheckBox {
	      name: "mark_mean";
	      label: qsTr("Mean")
	    }

      CheckBox {
	      name: "mark_median";
	      label: qsTr("Median")
	    }


      Label {
        text: qsTr("Spread")
      }

      CheckBox {
	      name: "mark_sd";
	      label: qsTr("Standard deviation")
	    }

      CheckBox {
	      name: "mark_quartiles";
	      label: qsTr("Quartiles")
	    }

      Label {
        text: qsTr("<i>z</i> scores")
      }

      CheckBox {
	      name: "mark_z_lines";
	      label: qsTr("<i>z</i> lines")
	    }

      Label {
        text: qsTr("")
      }


      Label {
        text: qsTr("Percentiles")
      }

      PercentField
		  {
		    name: "mark_percentile"
		    label: qsTr("Highlight bottom")
		    defaultValue: 0
		  }


    }  // end explore grid


	} // end explore


  Esci.ScatterplotOptions {
    title: qsTr("Figure options")
    sp_other_options_grid_enabled: false
    sp_other_options_grid_visible: false
    histogram_grid_visible: true
    sp_plot_width_defaultValue: 500
    sp_plot_height_defaultValue: 400


    Section
  {
    title: qsTr("Aesthetics")

    GridLayout {
      id: describe_aesthetics_grid
      columns: 2
      Layout.columnSpan: 2

      Label {
        text: qsTr("Bars and dots")
      }

      Esci.ColorSelect
      {
        name: "color"
        label: qsTr("Outline")
        startValue: 'black'
      }


      Label {
        text: qsTr("Not-highlighted")
      }

      Esci.ColorSelect
      {
        name: "fill_regular"
        label: qsTr("Fill")
        startValue: '#008DF9'
        id: fill_regular
      }

      Label {
        text: qsTr("Highlighted")
      }

      Esci.ColorSelect
      {
        name: "fill_highlighted"
        label: qsTr("Fill")
        startValue: '#E20134'
        id: fill_highlighted
      }

      Label {
        text: qsTr("Markers")
      }

      Esci.SizeSelect
      {
        label: qsTr("Size")
        name: "marker_size"
      }


    } // end describe_aesthetics_grid

  } // end aesthetics


  }

		Esci.ConfLevel
		  {
		    name: "conf_level"
		    id: conf_level
		    enabled: false
		    visible: false
		  }


}
