import QtQuick		2.12
import JASP.Module	1.0

Description
{
	name		: "jaspesci"
	title		: qsTr("esci")
	description	: qsTr("esci in JASP")
	version		: "0.1"
	author		: "Robert Calin-Jageman"
	maintainer	: "Robert Calin-Jageman <rcalinjageman@dom.edu>"
	website		: "https://thenewstatistics.com/"
	icon		: "esci_logo.svg"
	license		: "GPL (>= 2)"

	GroupTitle
	{
		title:	qsTr("Means and Medians")
	}

	Analysis
	{
		title:	qsTr("Single Group")
		func:	"jasp_estimate_mdiff_one"
	}

		Analysis
	{
		title:	qsTr("Two Groups")
		func:	"jasp_estimate_mdiff_two"
	}


}
