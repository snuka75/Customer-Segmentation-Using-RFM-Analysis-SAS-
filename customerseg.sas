proc import datafile="/home/u64235198/Online Retail.xlsx" out=online_retail 
		dbms=xlsx replace;
	sheet="Online Retail";
	getnames=yes;
run;

data retail_clean;
	set online_retail;

	/* Remove negative Quantity and UnitPrice */
	if Quantity > 0 and UnitPrice > 0;

	/* Keep only valid Customer IDs */
	if CustomerID ^=.;

	/* Calculate TotalSpend per line item */
	TotalSpend=Quantity * UnitPrice;
run;

proc sort data=retail_clean nodupkey;
	by InvoiceNo StockCode Quantity UnitPrice CustomerID InvoiceDate;
run;

data retail_clean;
	set retail_clean;
	format InvoiceDate datetime20.;
run;

proc sql;
	create table rfm as select CustomerID, count(distinct InvoiceNo) as Frequency, 
		sum(TotalSpend) as Monetary, max(InvoiceDate) as LastPurchase from 
		retail_clean group by CustomerID;
quit;

data rfm;
	set rfm;
	format AnalysisDate LastPurchase date9.;
	AnalysisDate='10DEC2011'd;
	Recency=AnalysisDate - datepart(LastPurchase);

	/* if InvoiceDate is datetime */
run;

data rfm;
	set rfm;

	if Recency >=0 and Frequency > 0 and Monetary > 0;
run;

proc standard data=rfm mean=0 std=1 out=rfm_scaled;
	var Recency Frequency Monetary;
run;

proc fastclus data=rfm_scaled maxclusters=4 out=rfm_clustered maxiter=100 
		converge=0;
	var Recency Frequency Monetary;
run;

proc means data=rfm_clustered n mean std min max maxdec=2;
	class cluster;
	var Recency Frequency Monetary;
run;

data final_clusters;
	set rfm_clustered;
	length Segment $25;

	if cluster=0 then
		Segment="Loyal High Spenders";
	else if cluster=1 then
		Segment="Lost Customers";
	else if cluster=2 then
		Segment="Potential Loyalists";
	else if cluster=3 then
		Segment="Low-Value Customers";
run;

proc freq data=final_clusters;
	tables Segment / nocum nopercent;
run;

proc sgplot data=final_clusters;
	scatter x=Frequency y=Monetary / group=Segment;
	title "Frequency vs. Monetary by Segment";
run;

proc sgplot data=final_clusters;
	scatter x=Recency y=Frequency / group=Segment;
	title "Recency vs. Frequency by Segment";
run;

proc sgplot data=final_clusters;
	vbar Segment / datalabel;
	title "Customer Count by Segment";
run;

proc template;
	define statgraph SegmentPie;
		begingraph;
		layout region;
		piechart category=Segment / stat=freq datalabelcontent=all;
		endlayout;
		endgraph;
	end;
run;

proc sgrender data=final_clusters template=SegmentPie;
run;

proc sgplot data=final_clusters;
	scatter x=Frequency y=Monetary / group=Segment 
		markerattrs=(symbol=CircleFilled size=9);
	title "Frequency vs. Monetary by Segment";
run;

proc sgplot data=final_clusters;
	scatter x=Recency y=Frequency / group=Segment 
		markerattrs=(symbol=TriangleFilled size=9);
	title "Recency vs. Frequency by Segment";
run;

/* STEP 5: Box Plot - Recency */
proc sgplot data=final_clusters;
	vbox Recency / category=Segment;
	title "Recency Distribution by Segment";
run;

/* STEP 6: Box Plot - Frequency */
proc sgplot data=final_clusters;
	vbox Frequency / category=Segment;
	title "Frequency Distribution by Segment";
run;

/* STEP 7: Box Plot - Monetary */
proc sgplot data=final_clusters;
	vbox Monetary / category=Segment;
	title "Monetary Distribution by Segment";
run;