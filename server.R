
library(shiny)
library(ggplot2)
library(lubridate)
library(plyr)

# Global Vars loaded only once on startup of the server
asdadets <- read.csv("TrialDetails.csv", header=T)
asdadets$Date <- as.Date(asdadets$Date,"%d/%m/%Y")
asdadets$BrandNo <- as.factor(asdadets$BrandNo)
baseDate <- asdadets[1,1]
asdadets$ddw <- difftime(asdadets$Date, baseDate, units="weeks")
asdadets$ddwnum <- as.integer(as.numeric(asdadets$ddw))

asdabrands <- read.csv("TrialBrands.csv", header=T)
asdabrands$BrandNo <- as.factor(asdabrands$BrandNo)

asdamast <- read.csv("TrialMaster.csv", header=T)


shinyServer(function(input,output){
  
  # Determine data range based on range of weeks selected
  stDate <- baseDate + (0*7)
  enDate <- baseDate + (37*7) + 7
  
  asdarange <- asdadets[asdadets$Date>=stDate & asdadets$Date<=enDate,]
  
  slsbydate <- aggregate(Dispensed ~ Date,data=asdarange,FUN="sum")
  
  slsbyweek <- aggregate(Dispensed ~ ddwnum, data=asdarange, FUN="sum")
  colnames(slsbyweek)[1] <- "WeekNo"
  
  slsbyhour <- aggregate(Dispensed ~ Hour,data=asdarange,FUN="sum")
  
  ## match up the TXNRef master info with the sales details
  m <- merge(asdarange, asdamast, by="TXNRef", all.x=TRUE)
  
  slsbyqty <- aggregate(Dispensed ~ TXNQty,data=m,FUN="sum")
  
  ## match up the brand details with the sales details
  mb <- merge(asdarange, asdabrands, by="BrandNo", all.x=TRUE)
  
  slsbycat <- aggregate(Dispensed ~ Category,data=mb,FUN="sum")
  
  slsbysize <- aggregate(Dispensed ~ Category + Size,data=mb,FUN="sum")
  slsbysize <- arrange(slsbysize, Category, Size)
  slsbysize$cSize <- factor(slsbysize$Size, as.character(slsbysize$Size))
  slsbysize$fullSize <- paste0(substr(slsbysize$Category,0,2),"-",slsbysize$cSize)
  
  # dispensed by brandno
  slsbybrand <- aggregate(Dispensed ~ BrandNo,data=mb,FUN="sum")
  
  slsbybrand <- merge(slsbybrand, asdabrands, by="BrandNo", all.x=TRUE)
  
  # sort by dispensed (descending) and brandno
  mb <- arrange(slsbybrand, desc(Dispensed), BrandNo)
  # add identity field (recno)
  mb$Id <- seq(1, nrow(mb))
  # get top 15
  slsbytop15 <- mb[mb$Id<=15,]
  # create char based brandno to maintain order of presentation
  slsbytop15$cBrandNo <- factor(slsbytop15$BrandNo, as.character(slsbytop15$BrandNo))

  wktxt <- "Week: 0 to 37"
  
  output$weekRangeToShow <- renderText({
    wktxt <- cat( "(Week:",0," to ",37, ")" )
	wktxt
  }) 
  
  output$chartSelected <- renderPlot({
    
    par(mar=c(4,4,2,1))
    if (input$chartType=="Requests by Week") {
      p  <- qplot(x=WeekNo, y=Dispensed, data=slsbyweek, 
            geom="bar", stat="identity", position="dodge",
            main=paste("Requests by Week", wktxt), fill=Dispensed)
    } else if (input$chartType=="Requests by Category") {
      p <- qplot(x=Category, y=Dispensed, data=slsbycat, 
            geom="bar", stat="identity", position="dodge",
            main="Requests by Category", fill=Dispensed)    
    } else if (input$chartType=="Requests by Size") {
      p <- qplot(x=fullSize, y=Dispensed, data=slsbysize,   
            geom="bar", stat="identity", position="dodge", na.rm=TRUE,
            main="Requests by Category and Size", fill=Dispensed,
            xlab="")      
    } else if (input$chartType=="Requests by Hour") {
      p <- qplot(x=Hour, y=Dispensed, data=slsbyhour, 
            geom="bar", stat="identity", position="dodge",
            main="Requests by Hour", fill=Dispensed,
            xlab="")      
    } else if (input$chartType=="Requests by Quantity") {
      p <- qplot(x=TXNQty, y=Dispensed, data=slsbyqty, 
            geom="bar", stat="identity", position="dodge",
            main="Requests by Quantity", fill=Dispensed,
            xlab="")
    } else if (input$chartType=="Top 15 Brands") {
      #p <- barplot(slsbytop15$Dispensed,axes=FALSE,col="blue")
      #p <- qplot(x=cBrandNo, y=Dispensed, data=slsbytop15, 
       #     geom="bar", stat="identity", position="dodge",
        #    main="Top 15 Brands", fill=Dispensed,
         #   xlab="")
    }
    if (input$chartType=="Top 15 Brands") {
      par(mar=c(10,4,2,1))
      bp <- barplot(slsbytop15$Dispensed,axes=FALSE,col="blue",main="Top 15 Brands")
      labels <- paste(slsbytop15$cBrandNo,slsbytop15$Description)
      text(bp,par("usr")[3],labels=labels,srt=45,adj=c(1.1,1.1),xpd=TRUE,cex=.9)
      axis(2)
    } else {
      title <- paste(input$chartType)
      print(p + ggtitle(title))
    }
    
  })
  
  output$datasetTable <- renderTable({
    if (input$chartType=="Requests by Week") {
      slsbyweek    
    } else if (input$chartType=="Requests by Category") {
      slsbycat
    } else if (input$chartType=="Requests by Size") {
      slsbysize
    } else if (input$chartType=="Requests by Hour") {
      slsbyhour
    } else if (input$chartType=="Requests by Quantity") {
      slsbyqty
    } else if (input$chartType=="Top 15 Brands") {
      slsbytop15
    }
    
  })
  
  # you can also define your own reactive expression with reactive()
  myReactiveExpression <-  reactive({
    input$range  
  })  
}

  
)