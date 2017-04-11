library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  #titlePanel("Sentiment Analysis"),
    headerPanel(
      
      tags$div(
        
    h1("Collaborative Multi-Domain Sentiment Analysis", 
       style = "font-family: 'Lobster', cursive;
       font-weight: 500; line-height: 1.3; text-align: center;
       color: #ad1d28;"))
    ),#headend
    mainPanel(
      tags$div(
      textInput("keyword", label = h3("Enter keyword")),
      
      submitButton("Submit"), style="border-style: solid;float:left;border-color:red;"
      ),#tagdiv end,
      
      
      tags$div(
        
        imageOutput("text1") ,style="border-style: solid;clear:left;float:left;border-color:red;"
        
      ),
      
        
        plotOutput("word")
    
      
    
    )#mainpanel end
  
))##shinyfluid ends