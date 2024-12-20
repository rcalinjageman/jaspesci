import QtQuick
import JASP.Controls
import JASP
import "./" as Esci

  Section
  {
    title: qsTr("Figure options")

     GridLayout {
      id: fgrid
      columns: 3

     Label {
        text: qsTr("<b>Dimensions</b>")
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
        defaultValue: 750
        min: 100
        max: 3000
      }

     Label {
        text: qsTr("<b><i>Y</i> axis</b>")
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
        text: qsTr("<b><i>X</i> axis</b>")
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
        text: qsTr("<b>Difference axis</b>")
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
        text: qsTr("<b>Sample-size scaling</b>")
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


    }  // end of figure options layout group



} // end of figure options rollup
