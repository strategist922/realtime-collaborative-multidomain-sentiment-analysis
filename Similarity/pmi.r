#  source(file = "get_lex.r",local = FALSE)
  sentiscore<- function(i_ndomain,domains)
  {
    domain_name<-paste(domains[i_ndomain],"lex_dt",sep="_")
    data1<-unique(get(domain_name))[lexicon_name!=""]
    posLabel1<-data1[value==1,sum(count)]
    negLabel1<-data1[value==-1,sum(count)]
    N1<-data1[,sum(count)]
    term_freq<-data1[,.(count=sum(count)),by=lexicon_name]
    all_terms<-term_freq[,lexicon_name]
    pos_data1<-data1[value==1]
    pos_term_freq<- pos_data1[,.(count=sum(count)),by=lexicon_name]
    neg_data1<-data1[value==-1]
    neg_term_freq<- neg_data1[,.(count=sum(count)),by=lexicon_name]
    pos_missing_terms<-setdiff(term_freq[,lexicon_name], pos_term_freq[,lexicon_name])
    pos_missing_freq<-data.table(lexicon_name=pos_missing_terms,count=N1)
    neg_missing_terms<-setdiff(term_freq[,lexicon_name], neg_term_freq[,lexicon_name])
    neg_missing_freq<-data.table(lexicon_name=neg_missing_terms,count=N1)
    
    pos_term_freq_n1<- pos_term_freq[,.(lexicon_name,count=count*N1)]
    term_freq_posLabel1<-term_freq[,.(lexicon_name,count=count*posLabel1)]
    neg_term_freq_n1<- neg_term_freq[,.(lexicon_name,count=count*N1)]
    term_freq_negLabel1<-term_freq[,.(lexicon_name,count=count*negLabel1)]
    pos_term_freq_n1<-rbind(pos_term_freq_n1,pos_missing_freq)
    neg_term_freq_n1<-rbind(neg_term_freq_n1,neg_missing_freq)
    
    #Sort the data tables according to lexicon names
    setkey(pos_term_freq_n1,lexicon_name)
    setkey(neg_term_freq_n1,lexicon_name)
    setkey(term_freq_posLabel1,lexicon_name)
    setkey(term_freq_negLabel1,lexicon_name)
    
    s1<-pos_term_freq_n1[,count]/term_freq_posLabel1[,count]
    s2<-neg_term_freq_n1[,count]/term_freq_negLabel1[,count]
    
    s1<-log(s1)
    
    #s1[s1==-Inf]<-0
    s2<-log(s2)
    #s2[s2==-Inf]<-0
    
    s<-s1-s2
  
    return(list(lexicon_name=pos_term_freq_n1[,lexicon_name],score=s))
  }
  
  calcSim<-function(data_dt1=books_score,data_dt2=kitchen_score)
  {
   # data_dt1=kitchen_score;data_dt2=electronics_score
    missing_data1<-data.table(lexicon_name=setdiff(data_dt2[,lexicon_name],data_dt1[,lexicon_name]),score=0)
    missing_data2<-data.table(lexicon_name=setdiff(data_dt1[,lexicon_name],data_dt2[,lexicon_name]),score=0)
    data_dt1<-setkey(rbind(data_dt1,missing_data1),lexicon_name)
    data_dt2<-setkey(rbind(data_dt2,missing_data2),lexicon_name)
    s1<- t(data_dt1[,score])%*%data_dt2[,score]
    s2<-sqrt(sum(data_dt1[,score]^2))*sqrt(sum(data_dt2[,score]^2))
    s<-s1/s2;
    if(s<0) s<-0
    s[1]
  }
  
  domains=c("books","dvd","kitchen","electronics")
  Domains_index<-1:length(domains)
  for(i in 1:length(domains))
  {
    x<-sentiscore(i,domains)
    assign(paste(domains[i],"score",sep = "_"),as.data.table(x))
  }
  SentiSim<-matrix(data = 0,nrow = length(domains),ncol = length(domains))
  
  for( i in 1:length(domains))
  {
    for( j in 1:length(domains))
    {
      if(i<j)
     SentiSim[i,j]<-calcSim(get(paste(domains[i],"score",sep = "_")),get(paste(domains[j],"score",sep = "_")))
      else if(i==j)
        SentiSim[i,j]<-0
      else
        SentiSim[i,j]<-SentiSim[j,i]
    }
  }
SentiSim<-(SentiSim>0.5)+0