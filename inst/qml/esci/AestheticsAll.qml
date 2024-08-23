import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

    Section
  {
    title: qsTr("Aesthetics")

    GridLayout {
      id: grid
      columns: 5


      Label {
        text: " "
      }

      Label {
        text: "Reference"
      }


      Label {
        text: "Comparison"
      }


      Label {
        text: "Difference"
      }

      Label {
        text: "Unused"
      }

      Label {
        text: "Summary"
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
        name: "shape_summary_reference"
        id: shape_summary_reference
        startValue: 'circle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_comparison"
        id: shape_summary_comparison
        startValue: 'circle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_difference"
        id: shape_summary_difference
        startValue: 'triangle filled'
      }

      Esci.ShapeSelect
      {
        name: "shape_summary_unused"
        id: shape_summary_unused
        startValue: 'circle filled'
      }


      Label {
        text: qsTr("Size")
      }

      Esci.SizeSelect
      {
        name: "size_summary_reference"
        id: size_summary_reference

      }

      Esci.SizeSelect
      {
        name: "size_summary_comparison"
        id: size_summary_comparison

      }

      Esci.SizeSelect
      {
        name: "size_summary_difference"
        id: size_summary_difference

      }

      Esci.SizeSelect
      {
        name: "size_summary_unused"
        id: size_summary_unused
      }


      Label {
        text: qsTr("Outline")
      }

      Esci.ColorSelect
      {
        name: "color_summary_reference"
        id: color_summary_reference
        startValue: "#008DF9"
      }

      Esci.ColorSelect
      {
        name: "color_summary_comparison"
        id: color_summary_comparison
        startValue: "#009F81"
      }

      Esci.ColorSelect
      {
        name: "color_summary_difference"
        id: color_summary_difference
        startValue: 'black'
      }

      Esci.ColorSelect
      {
        name: "color_summary_unused"
        id: color_summary_unused
        startValue: 'gray65'
      }


      Label {
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_summary_reference"
        id: fill_summary_reference
        startValue: "#008DF9"
      }

      Esci.ColorSelect
      {
        name: "fill_summary_comparison"
        id: fill_summary_comparison
        startValue: "#009F81"
      }

      Esci.ColorSelect
      {
        name: "fill_summary_difference"
        id: fill_summary_difference
        startValue: 'black'
      }

      Esci.ColorSelect
      {
        name: "fill_summary_unused"
        id: fill_summary_unused
        startValue: 'gray65'
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_reference"
        id: alpha_summary_reference

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_comparison"
        id: alpha_summary_comparison

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_difference"
        id: alpha_summary_difference

      }

      Esci.AlphaSelect
      {
        name: "alpha_summary_unused"
        id: alpha_summary_unused
      }

      Label {
        text: qsTr("CI")
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
        name: "linetype_summary_reference"
        id: linetype_summary_reference
      }

      Esci.LineTypeSelect
      {
        name: "linetype_summary_comparison"
        id: linetype_summary_comparison
      }

      Esci.LineTypeSelect
      {
        name: "linetype_summary_difference"
        id: linetype_summary_difference
      }

      Esci.LineTypeSelect
      {
        name: "linetype_summary_unused"
        id: linetype_summary_unused
      }


      Label {
        text: qsTr("Thickness")
      }

      IntegerField
      {
        name: "size_interval_reference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: effect_size.currentValue == "mean_difference"
      }

      IntegerField
      {
        name: "size_interval_comparison"
        defaultValue: 3
        min: 1
        max: 10
        enabled: effect_size.currentValue == "mean_difference"
      }

      IntegerField
      {
        name: "size_interval_difference"
        defaultValue: 3
        min: 1
        max: 10
        enabled: effect_size.currentValue == "mean_difference"
      }

      IntegerField
      {
        name: "size_interval_unused"
        defaultValue: 3
        min: 1
        max: 10
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: qsTr("Color")
      }

      Esci.ColorSelect
      {
        name: "color_interval_reference"
        id: color_interval_reference
        startValue: 'black'
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "color_interval_comparison"
        id: color_interval_comparison
        startValue: 'black'
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "color_interval_difference"
        id: color_inteval_difference
        startValue: 'black'
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "color_interval_unused"
        id: color_inteval_unused
        startValue: 'gray65'
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_reference"
        id: alpha_interval_reference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_comparison"
        id: alpha_interval_comparison
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_difference"
        id: alpha_interval_difference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_interval_unused"
        id: alpha_interval_unused
        enabled: effect_size.currentValue == "mean_difference"
      }

      Label {
        text: qsTr("Error distribution")
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
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_error_reference"
        id: fill_error_reference
        startValue: "gray75"
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "fill_error_comparison"
        id: fill_error_comparison
        startValue: "gray75"
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "fill_error_difference"
        id: fill_error_difference
        startValue: 'gray75'
        enabled: effect_size.currentValue == "mean_difference"
      }

      Esci.ColorSelect
      {
        name: "fill_error_unused"
        id: fill_error_unused
        startValue: 'gray75'
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_error_reference"
        id: alpha_error_reference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_comparison"
        id: alpha_error_comparison
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_difference"
        id: alpha_error_difference
        enabled: effect_size.currentValue == "mean_difference"

      }

      Esci.AlphaSelect
      {
        name: "alpha_error_unused"
        id: alpha_error_unused
        enabled: effect_size.currentValue == "mean_difference"
      }


      Label {
        text: "Raw data"
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
        startValue: 'circle filled'
        enabled: from_raw.checked | mixed.checked
      }

      Esci.ShapeSelect
      {
        name: "shape_raw_comparison"
        id: shape_raw_comparison
        startValue: 'circle filled'
        enabled: from_raw.checked | mixed.checked
      }

      Label {
        text: " "
      }

      Esci.ShapeSelect
      {
        name: "shape_raw_unused"
        id: shape_raw_unused
        startValue: 'circle filled'
        enabled: from_raw.checked | mixed.checked
      }


      Label {
        text: qsTr("Size")
      }

      Esci.SizeSelect
      {
        name: "size_raw_reference"
        id: size_raw_reference
        defaultValue: 2
        enabled: from_raw.checked | mixed.checked

      }

      Esci.SizeSelect
      {
        name: "size_raw_comparison"
        id: size_raw_comparison
        defaultValue: 2
        enabled: from_raw.checked | mixed.checked

      }

      Label {
        text: " "
      }

      Esci.SizeSelect
      {
        name: "size_raw_unused"
        id: size_raw_unused
        defaultValue: 1
        enabled: from_raw.checked | mixed.checked
      }


      Label {
        text: qsTr("Outline")
      }

      Esci.ColorSelect
      {
        name: "color_raw_reference"
        id: color_raw_reference
        startValue: "#008DF9"
        enabled: from_raw.checked | mixed.checked
      }

      Esci.ColorSelect
      {
        name: "color_raw_comparison"
        id: color_raw_comparison
        startValue: "#009F81"
        enabled: from_raw.checked | mixed.checked
      }

      Label {
        text: " "
      }

      Esci.ColorSelect
      {
        name: "color_raw_unused"
        id: color_raw_unused
        startValue: "gray65"
        enabled: from_raw.checked | mixed.checked
      }


      Label {
        text: qsTr("Fill")
      }

      Esci.ColorSelect
      {
        name: "fill_raw_reference"
        id: fill_raw_reference
        startValue: "NA"
        enabled: from_raw.checked | mixed.checked
      }

      Esci.ColorSelect
      {
        name: "fill_raw_comparison"
        id: fill_raw_comparison
        startValue: "NA"
        enabled: from_raw.checked | mixed.checked
      }

      Label {
        text: " "
      }

      Esci.ColorSelect
      {
        name: "fill_raw_unused"
        id: fill_raw_unused
        startValue: "NA"
        enabled: from_raw.checked | mixed.checked
      }


      Label {
        text: qsTr("Transparency")
      }

      Esci.AlphaSelect
      {
        name: "alpha_raw_reference"
        id: alpha_raw_reference
        enabled: from_raw.checked | mixed.checked

      }

      Esci.AlphaSelect
      {
        name: "alpha_raw_comparison"
        id: alpha_raw_comparison
        enabled: from_raw.checked | mixed.checked

      }

      Label {
        text: " "
      }

      Esci.AlphaSelect
      {
        name: "alpha_raw_unused"
        id: alpha_raw_unused
        enabled: from_raw.checked | mixed.checked

      }



    } // end aesthetics group


  } // end aesthetics
