#!/usr/bin/env Rscript

require(LaplacesDemon,quietly = T)

argsList = commandArgs(trailingOnly = T)

posterior = read.table(file = argsList[1],header = F,skip = 0)
burnins = seq(from=0,to=0.9,by=0.1)

goodOnes = numeric()
for(c in 2:ncol(posterior)){
  if(!all(posterior[,c] == floor(posterior[,c]))){
    goodOnes = c(goodOnes,c)
  }
}
posterior = posterior[,goodOnes]
# menorESS = nrow(posterior)
# melhorESS = 0
melhorBurnin = 0
# melhorBurninByCols = rep(0,ncol(posterior))
maiorESSbyCols = rep(0,ncol(posterior))
  
for(b in burnins){
  
  firstIndex = floor(nrow(posterior)*b)+1
  lastIndex = nrow(posterior)
  
  for(c in 1:ncol(posterior)){
    
    coluna = posterior[firstIndex:lastIndex,c]
    essValue = ESS(coluna)
    if(essValue > maiorESSbyCols[c]){
      maiorESSbyCols[c] = essValue
      if(melhorBurnin < firstIndex){
        melhorBurnin = firstIndex
      }
    }
    # if(essValue < menorESS){
    #   menorESS = essValue
    # }
  }
  
  # print(paste(b,menorESS))
  
  # if(menorESS > melhorESS){
  #   melhorESS = menorESS
  # }
  
}

cat(melhorBurnin," ",min(maiorESSbyCols),"\n")
 

