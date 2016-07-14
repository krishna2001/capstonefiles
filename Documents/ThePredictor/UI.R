library(shiny) 
library(shinyapps)
shinyUI(fluidPage( 
     titlePanel("The Predictor"), 
     sidebarLayout(
     sidebarPanel( 
         h4('This is a function that allows you to predict the next word based on your inputed text.'), 
         h4('The prediction is based on a large grouping of news articles, blogs and twitter posts.'), 
         h4('The prediction function will "clean" your text, removing punctuation, whitespace, numbers and profanity for accuracy.'), 
         h4('Note that very common words like THE have been removed.'), 
         h4('Your initial attempt may take a moment while the files load.  Thank you for your patience.'), 
         textInput("inputtext", label=h3("Enter Your Text Here"), value="Happy Mother's"), 
         submitButton('Submit') 
         ), 
     mainPanel( 
         h3('The top predictions for the Next Word are',style="color:red"), 
         h4('Number 1', style="color:blue"),
         verbatimTextOutput("pred1"),
         h4('Number 2', style="color:blue"),
         verbatimTextOutput("pred2"),
         h4('Number 3', style="color:blue"),
         verbatimTextOutput("pred3"),
         h4('Number 4', style="color:blue"),
         verbatimTextOutput("pred4"),
         h4('Number 5', style="color:blue"),
         verbatimTextOutput("pred5")
         ) 
      ) 
     ) 
    )