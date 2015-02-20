## Introduction

This is an example project for the Data Products course from
the Coursera website, it provides an example of a SHINY project
which when run (via runApp()) allows you to see the results of
a fictitious analysis of sales of various brands/products sold
over weekly periods.

The project assignment is to demonstrate basic knowledge for 
programming the shiny web interface and subsequently the 
deployment of same on an RStudio shiny server.

You can find this shiny app at the following URL:

https://dataprods.shinyapps.io/dataprods

## Data

The data for this app can be found in the github repository.

The following data files were used:-

TrialMaster.csv
TrialDetails.csv
TrialBrands.csv

TrialMaster contains transaction level information, of main in
are the quantities sold.

TrialDetails contains the brands per transaction and links to 
TrialMaster.

TrialBrands contains branding information to enable top sellers 
and category based sales to be determined.

The dataset is stored in a comma-separated-value (CSV) files.

TrialMaster.csv has 112,784 observations and 2 field TXNRef, TXNQty
TrialDetails.csv has 145,244 observations and the following fields: Date,Hour,BrandNo,Slot,Requested,Dispensed,Empty,Error,TXNRef
TrialBrands.csv has 174 observations and the following fields: BrandNo,Description,Category,SubCategory,Size,Price


## Assignment

Create a server.R and UI.R that satisfies a shiny app.

UI.R presents the Trial Analysis page, it contains a drop down list
from which the user can choose the type of graph to view.  The user
then clicks the 'Refresh the Graph' button to view the graph.  The 
graph output is shown to the right within a TAB set and you can select
to view the graph data too.

server.R on startup preloads the datasets to aid the performance of the 
graphing activity.  The data is then prepared and presented based upon
the chartType selected in the UI drop down list.

