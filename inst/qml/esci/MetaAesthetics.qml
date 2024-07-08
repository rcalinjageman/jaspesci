import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

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

      } // aesthetics group


    } // aesthetics section
