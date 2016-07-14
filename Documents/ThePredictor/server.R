# load necessary libraries 
library(shiny) 
library(shinyapps)
library(tm) 
library(knitr) 
library(R.utils) 
library(rsconnect)
library(devtools) 
memory.size(max=20000)


#Next, we will load the data and read in the necessary files. 

load("unibitriDF.RData") 
load("unibiDF.RData") 
load("unigramDF.RData")


cleanit<-function(chrfile)  { 
cleaned <- tolower(chrfile) 
cleaned<-removePunctuation(cleaned) 
cleaned<-removeNumbers(cleaned) 
FCCbadwords<-c("fuck", "shit", "piss", "cunt", "cocksucker", "motherfucker", "tits") 
cleaned <- removeWords(cleaned, FCCbadwords) 
cleaned <- stripWhitespace(cleaned) 
return(cleaned) 
 } 


numberofwords<-function(str1) { 
words <- sapply(gregexpr("[[:alpha:]]+", str1), function(x) sum(x > 0)) 
return(words) 
 } 



predicttri<-function(word2, word1) { 
trisubDF<-unibitriDF[unibitriDF$FirstWord==word1 & unibitriDF$SecondWord==word2,]  
ordtrisubDF<-trisubDF[order(trisubDF$TriProb, trisubDF$BiProb, trisubDF$UniFreq, decreasing=TRUE),] 
ordtop5<-ordtrisubDF[1:5,] 
finaltri<-ordtop5[complete.cases(ordtop5),] 
return(finaltri$ThirdWord) 
   } 


predictbi<-function(wordb) { 
bisubDF<-unibiDF[unibiDF$FirstWord==wordb,]  
ordbisubDF<-bisubDF[order(bisubDF$BiProb, bisubDF$UniFreq, decreasing=TRUE),] 
ordbitop5<-ordbisubDF[1:5,] 
finalbi<-ordbitop5[complete.cases(ordbitop5),] 
return(finalbi$SecondWord) 
 } 

preduni<-unigramDF[order(unigramDF$unifreq, decreasing=TRUE),]
unitop10<-preduni[1:10,]
finaluni<-unitop10$uninames



predictor<-function(worddeux, wordun) { 
testword1<-unibitriDF$FirstWord==wordun & unibitriDF$SecondWord==worddeux 
testword2<-unibiDF$FirstWord==worddeux
testword4<-unibitriDF$FirstWord==wordun
nomark<-0
startpoint<-0
starter<-0
if (sum(testword1)>0) { 
    predword<-predicttri(worddeux,wordun) 
      } else if (sum(testword2)>0) { 
            predword<-predictbi(worddeux) 
            } else nomark<-1

if (nomark==1) {
  predword<-finaluni
}

if ((length(predword)<5) & (sum(testword2)>0) & (sum(testword1)>0)) {
  startpoint<-length(predword) + 1
  bifillers<-predictbi(worddeux)
  for (i in startpoint:5) {
    predword[i]<-bifillers[i-startpoint+1]
  }
}

predword<-unique(predword)

if ((nomark==1) & (sum(testword4)>0) & (sum(testword1)==0)) {
      predword<-predictbi(wordun)
  }


predword<-unique(predword)





if (is.na(predword[2])) {
  for (i in 2:9) {
    predword[i]<-finaluni[i-1]
  } 
  } else if (is.na(predword[3])) {
     for (i in 3:10) {
       predword[i]<-finaluni[i-2]
    }
  }   else if (is.na(predword[4])) {
         for (i in 4:11) {
           predword[i]<-finaluni[i-3]
    }
  }     else if (is.na(predword[5])) {
          for (i in 5:12) {
            predword[i]<-finaluni[i-4]
    }
         }

predword<-unique(predword)
predword<-na.omit(predword)
return(predword)
} 


shinyServer( 
     function(input,output) { 
         input2 <- reactive(as.character(cleanit(input$inputtext))) 
         n<-reactive(as.numeric(numberofwords(input2()))) 
         inputword2<-reactive(as.character(sapply(strsplit(input2(), ' '), function(a) a[n()]))) 
         inputword1<-reactive(as.character(sapply(strsplit(input2(), ' '), function(a) a[n()-1]))) 
         predword<-reactive(as.character(predictor(inputword2(),inputword1())))
         output$pred1<-renderText({predword()[1]}) 
         output$pred2<-renderText({predword()[2]})
         output$pred3<-renderText({predword()[3]})
         output$pred4<-renderText({predword()[4]})
         output$pred5<-renderText({predword()[5]})
        } 
   ) 
