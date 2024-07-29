import QtQuick		2.12
import JASP.Module	1.0

Description
{
	name		    : "jaspesci"
	title		    : qsTr("esci")
	description	: qsTr("esci in JASP")
	version		  : "0.1"
	author		  : "Robert Calin-Jageman"
	maintainer	: "Robert Calin-Jageman <rcalinjageman@dom.edu>"
	website		  : "https://thenewstatistics.com/"
	icon		    : "esci_logo.svg"
	license		  : "GPL (>= 2)"

	Analysis
	{
		title:	qsTr("esci: Describe")
		menu:	qsTr("Describe")
		func:	"jasp_describe"
	}

	GroupTitle
	{
		title:	qsTr("Means and Medians")
	}

	Analysis
	{
		title:	qsTr("esci Means and Medians: Single Group")
		menu:	qsTr("Single Group")
		func:	"jasp_estimate_mdiff_one"
	}

	Analysis
	{
		title:	qsTr("esci Means and Medians: Two Groups")
		menu:	qsTr("Two Groups")
		func:	"jasp_estimate_mdiff_two"
	}

	Analysis
	{
		title:	qsTr("esci Means and Medians: Paired")
		menu:	qsTr("Paired")
		func:	"jasp_estimate_mdiff_paired"
	}


	GroupTitle
	{
		title:	qsTr("Correlations")
	}

	Analysis
	{
		title:	qsTr("esci Correlations: Single Group")
		menu:	qsTr("Single Group")
		func:	"jasp_estimate_r"
	}

	Analysis
	{
		title:	qsTr("esci Correlations: Two Groups")
		menu:	qsTr("Two Groups")
		func:	"jasp_estimate_rdiff_two"
	}


	GroupTitle
	{
		title:	qsTr("Proportions")
	}

	Analysis
	{
		title:	qsTr("esci Proportions: Single Group")
		menu:	qsTr("Single Group")
		func:	"jasp_estimate_pdiff_one"
	}

	Analysis
	{
		title:	qsTr("esci Proportions: Two Groups")
		menu:	qsTr("Two Groups")
		func:	"jasp_estimate_pdiff_two"
	}

	Analysis
	{
		title:	qsTr("esci Proportions: Paired")
		menu:	qsTr("Paired")
		func:	"jasp_estimate_pdiff_paired"
	}


	GroupTitle
	{
		title:	qsTr("Meta-Analysis")
	}

	Analysis
	{
		title:	qsTr("esci Meta-Analysis: Means")
		menu:	qsTr("Means")
		func:	"jasp_meta_mean"
	}

	Analysis
	{
		title:	qsTr("esci Meta-Analysis: Difference in Means")
		menu:	qsTr("Difference in Means")
		func:	"jasp_meta_mdiff_two"
	}

	Analysis
	{
		title:	qsTr("esci Meta-Analysis: Correlations")
		menu:	qsTr("Correlations")
		func:	"jasp_meta_r"
	}

	Analysis
	{
		title:	qsTr("esci Meta-Analysis: Proportions")
		menu:	qsTr("Proportions")
		func:	"jasp_meta_proportion"
	}

		Analysis
	{
	  title: qsTr("esci Meta-Anlaysis: Difference in Proportions")
		menu:	qsTr("Difference in Proportions")
		func:	"jasp_meta_pdiff_two"
	}

}
