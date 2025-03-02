import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import "./" as Esci

  Section
  {
    title: qsTr("Figure options")

     GridLayout {
      id: fgrid
      columns: 5
      rowSpacing:    jaspTheme.rowGroupSpacing
      columnSpacing: jaspTheme.columnGroupSpacing

      // 0.7 is obtained via trial and error
      property double adjustedFieldWidth: 0.7 * jaspTheme.textFieldWidth

     Label {
        text: qsTr("<b>Dimensions</b>")
      }

     Label {
        text: qsTr("Width")
      }

    IntegerField
      {
        name: "width"
        defaultValue: 600
        min: 100
        max: 3000
        fieldWidth: fgrid.adjustedFieldWidth
      }

     Label {
        text: qsTr("Height")
      }


    IntegerField
      {
        name: "height"
        defaultValue: 750
        min: 100
        max: 3000
        fieldWidth: fgrid.adjustedFieldWidth
      }

     Label {
        text: qsTr("<b><i>Y</i> axis</b>")
      }

     Label {
        text: qsTr("Diamond height")
      }

      DoubleField
      {
        name: "meta_diamond_height"
        defaultValue: 0.25
        min: 0
        max: 5
        fieldWidth: fgrid.adjustedFieldWidth
      }

     Label {
        text: qsTr("Include CIs")
      }


  	  CheckBox {
  	    name: "report_CIs";
  	  }

  	  Label {
        text: " "
      }

  	  Label {
        text: qsTr("Tick Font Size")
      }

  	   IntegerField
      {
        name: "axis.text.y"
        defaultValue: 14
        min: 2
        max: 80
        fieldWidth: fgrid.adjustedFieldWidth
      }

      Label {
        text: " "
      }

  	  Label {
        text: " "
      }


       Label {
        text: qsTr("<b><i>X</i> axis</b>")
      }

  	  Label {
        text: qsTr("Label")
      }

      TextField {
        name: "xlab"
        placeholderText: "auto"
        fieldWidth: fgrid.adjustedFieldWidth * 2
        Layout.columnSpan: 3
      }


      Label {
        text: " "
      }

  	  Label {
        text: qsTr("Tick Font Size")
      }

      IntegerField {
        name: "axis.text.x"
        defaultValue: 14
        min: 2
        max: 80
        fieldWidth: fgrid.adjustedFieldWidth
    }

  	  Label {
        text: qsTr("Label Font Size")
      }


    IntegerField {
        name: "axis.title.x"
        defaultValue: 15
        min: 2
        max: 80
        fieldWidth: fgrid.adjustedFieldWidth
    }

     Label {
        text: " "
      }

     Label {
        text: qsTr("Min")
      }

    TextField {
        name: "xmin"
        placeholderText: "auto"
        fieldWidth: fgrid.adjustedFieldWidth
    }

     Label {
        text: qsTr("Max")
      }


    TextField {
        name: "xmax"
        placeholderText: "auto"
        fieldWidth: fgrid.adjustedFieldWidth
    }

     Label {
        text: " "
      }

     Label {
        text: qsTr("Num. tick marks")
      }


      TextField {
        name: "xbreaks"
        placeholderText: "auto"
        fieldWidth: fgrid.adjustedFieldWidth
      }

     Label {
        text: qsTr("Mark zero")
      }

      CheckBox {
  	    name: "mark_zero";
  	    checked: false
  	}

  	 Label {
        text: qsTr("<b>Difference axis</b>")
      }

  	 Label {
        text: qsTr("Label")
      }

      TextField {
        name: "dlab"
        placeholderText: "auto"
        enabled: moderator.count > 0
        fieldWidth: fgrid.adjustedFieldWidth * 2
        Layout.columnSpan: 3
      }

     Label {
        text: " "
      }

     Label {
        text: qsTr("Min")
      }

    TextField {
        name: "dmin"
        placeholderText: "auto"
        enabled: moderator.count > 0
        fieldWidth: fgrid.adjustedFieldWidth
      }

     Label {
        text: qsTr("Max")
      }

      TextField {
        name: "dmax"
        placeholderText: "auto"
        enabled: moderator.count > 0
        fieldWidth: fgrid.adjustedFieldWidth
      }

      Label {
        text: " "
      }

     Label {
        text: qsTr("Num. tick marks")
      }


       TextField {
        name: "dbreaks"
        placeholderText: "auto"
        enabled: moderator.count > 0
        fieldWidth: fgrid.adjustedFieldWidth
      }

      Label {
        text: " "
      }


            Label {
        text: " "
      }

      Label {
        text: qsTr("<b>Sample-size scaling</b>")
      }

      Label {
        text: qsTr("Minimum")
      }


       DoubleField {
        name: "size_base"
        defaultValue: 2
        min: 0.25
        max: 8
        fieldWidth: fgrid.adjustedFieldWidth
      }

      Label {
        text: qsTr("Multiplier")
      }

      DoubleField {
        name: "size_multiplier"
        defaultValue: 3
        min: 1
        max: 5
        fieldWidth: fgrid.adjustedFieldWidth
      }


    }  // end of figure options layout group



} // end of figure options rollup
