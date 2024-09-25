mydata = read.csv('../Data/bigtable.csv',header=TRUE,stringsAsFactors=FALSE)
diversity = read.csv('../SimilarityValues/recommendations_diversity_from_up.csv',header=FALSE,stringsAsFactors=FALSE)
colnames(diversity) <- c('user_id','pid','diversity')
diversity_up = read.csv('../SimilarityValues/mean_up.csv', header = FALSE,stringsAsFactors=FALSE)
colnames(diversity_up) <-c("user_id","mean_div")
diversity_genre <- read.csv('../Data/part1_question2_cf.csv', stringsAsFactors=FALSE)

dataset1 <- merge(mydata, diversity, x.all=TRUE)
dataset2 <-merge(dataset1,diversity_up,x.all=TRUE) 
dataset <- merge(dataset2,diversity_genre, x.all=TRUE)

dataset$diversity <- 1- dataset$diversity
dataset$mean_div  <- 1- dataset$mean_div
#analysis of user profiles curiosity style and serendipity
dataset$watched[dataset$watched==yes]=1
dataset$watched[dataset$watched==no]=0
dataset$EC = 0
dataset$S = 0
dataset$D = 0
for(i in (1:dim(dataset)[1])){
  dataset$PC[i] = mean(c(dataset$discoverPlaces[i],dataset$listenMusic[i],dataset$strangeSound[i]))
  dataset$EC[i] = mean(c(dataset$learnSubjects[i],dataset$machinery[i],dataset$solution[i]))
  dataset$S[i] = mean(c(dataset$discoverPlaces[i],dataset$learnSubjects[i],dataset$listenMusic[i],dataset$machinery[i]))
  dataset$D[i] = mean(c(dataset$strangeSound[i],dataset$solution[i]))
}
dataset$PC_binary = 0
dataset$PC_binary[dataset$PC>3] =1

dataset$EC_binary = 0
dataset$EC_binary[dataset$EC>3] =1
#dataset$PC[dataset$discoverPlaces>=3 & dataset$listenMusic>=3 & dataset$strangeSound >=3]= mean(c(dataset$discoverPlaces,dataset$listenMusic,dataset$strangeSound))
#dataset$EC[dataset$learnSubjects>=3 & dataset$machinery>=3 & dataset$solution>=3]=mean(c(dataset$learnSubjects,dataset$machinery,dataset$solution))

#dataset$D[dataset$discoverPlaces>=3 & dataset$learnSubjects>=3 &dataset$listenMusic >=3 &dataset$machinery>=3]=1
#dataset$S[dataset$strangeSound>=3 & dataset$solution>=3]=1

#correlation tests
cor.test(dataset$PC, dataset$influenceDecision, method='spearman')
cor.test(dataset$PC, dataset$outOfScope, method='spearman')
cor.test(dataset$PC, dataset$unexpected, method='spearman')
cor.test(dataset$PC, dataset$usefulIdeas, method='spearman')

cor.test(dataset$EC, dataset$influenceDecision, method='spearman')
cor.test(dataset$EC, dataset$outOfScope, method='spearman')
cor.test(dataset$EC, dataset$unexpected, method='spearman')
cor.test(dataset$EC, dataset$usefulIdeas, method='spearman')

cor.test(dataset$S, dataset$influenceDecision, method='spearman')
cor.test(dataset$S, dataset$outOfScope, method='spearman')
cor.test(dataset$S, dataset$unexpected, method='spearman')
cor.test(dataset$S, dataset$usefulIdeas, method='spearman')

cor.test(dataset$D, dataset$influenceDecision, method='spearman')
cor.test(dataset$D, dataset$outOfScope, method='spearman')
cor.test(dataset$D, dataset$unexpected, method='spearman')
cor.test(dataset$D, dataset$usefulIdeas, method='spearman')



##logistic ordinal regression
library("aod")

regression_pc_influenceDecision <- glm(influenceDecision ~ PC  , data = dataset)
summary(regression_pc_influenceDecision)


regression_pc_outOfScope <- glm(outOfScope ~PC, data = dataset)
summary(regression_pc_outOfScope)
regression_pc_unexpected<-glm(unexpected~PC, data = dataset)
summary(regression_pc_unexpected)
regression_pc_usefulIdeas<-glm(usefulIdeas~PC, data = dataset)
summary(regression_pc_usefulIdeas)

regression_ec_influenceDecision <- glm(influenceDecision ~ EC  , data = dataset)
summary(regression_ec_influenceDecision)
regression_ec_outOfScope <- glm(outOfScope ~EC, data = dataset)
summary(regression_ec_outOfScope)
regression_ec_unexpected<-glm(unexpected~EC, data = dataset)
summary(regression_ec_unexpected)
regression_ec_usefulIdeas<-glm(usefulIdeas~EC, data = dataset)
summary(regression_ec_usefulIdeas)


#analysis of ratings
#############test serendipity with genre/format diversity in up + ls mean diversity in up
dataset$notInteresting[as.numeric(dataset$notInteresting)==9]=1
dataset$notInteresting[as.numeric(dataset$notInteresting)==8]=2
dataset$notInteresting[as.numeric(dataset$notInteresting)==7]=3
dataset$notInteresting[as.numeric(dataset$notInteresting)==6]=4
dataset$notInteresting[as.numeric(dataset$notInteresting)==3]=5
dataset$surprised[as.numeric(dataset$surprised)==9]=5
dataset$surprised[as.numeric(dataset$surprised)==8]=4
dataset$surprised[as.numeric(dataset$surprised)==7]=3
dataset$surprised[as.numeric(dataset$surprised)==6]=2
dataset$surprised[as.numeric(dataset$surprised)==3]=1
dataset$usuallyWatched[as.numeric(dataset$usuallyWatched)==9]=5
dataset$usuallyWatched[as.numeric(dataset$usuallyWatched)==8]=4
dataset$usuallyWatched[as.numeric(dataset$usuallyWatched)==7]=3
dataset$usuallyWatched[as.numeric(dataset$usuallyWatched)==6]=2
dataset$usuallyWatched[as.numeric(dataset$usuallyWatched)==3]=1
dataset$notUnderstand[as.numeric(dataset$notUnderstand)==9]=5
dataset$notUnderstand[as.numeric(dataset$notUnderstand)==8]=4
dataset$notUnderstand[as.numeric(dataset$notUnderstand)==7]=3
dataset$notUnderstand[as.numeric(dataset$notUnderstand)==6]=2
dataset$notUnderstand[as.numeric(dataset$notUnderstand)==3]=1



dataset[dataset$PC>3,] <- dataset[dataset$watched=="yes",]

dataset[dataset$PC<=3,] <- dataset[dataset$watched=="no",]

summary(glm(surprised ~ PC , data = dataset))
summary(glm(notInteresting ~PC, data=dataset))
summary(glm(usuallyWatched ~ PC, data = dataset))
summary(glm(notUnderstand ~ PC, data = dataset))

summary(glm(surprised ~ PC , data = dataset[dataset$PC>3,]))
summary(glm(notInteresting ~PC, data=dataset[dataset$PC>3,]))
summary(glm(usuallyWatched ~ PC, data = dataset[dataset$PC>3,]))
summary(glm(notUnderstand ~ PC, data = dataset[dataset$PC>3,]))

summary(glm(surprised ~ PC , data = dataset[dataset$PC<=3,]))
summary(glm(notInteresting ~PC, data=dataset[dataset$PC<=3,]))
summary(glm(usuallyWatched ~ PC, data = dataset[dataset$PC<=3,]))
summary(glm(notUnderstand ~ PC, data = dataset[dataset$PC<=3,]))

summary(glm(surprised ~ PC , data = dataset[dataset$EC>3,]))
summary(glm(notInteresting ~PC, data=dataset[dataset$EC>3,]))
summary(glm(usuallyWatched ~ PC, data = dataset[dataset$EC>3,]))
summary(glm(notUnderstand ~ PC, data = dataset[dataset$EC>3,]))

summary(glm(surprised ~ PC , data = dataset[dataset$EC<=3,]))
summary(glm(notInteresting ~PC, data=dataset[dataset$EC<=3,]))
summary(glm(usuallyWatched ~ PC, data = dataset[dataset$EC<=3,]))
summary(glm(notUnderstand ~ PC, data = dataset[dataset$EC<=3,]))

summary(glm(surprised ~ EC , data = dataset))
summary(glm(notInteresting ~EC, data=dataset))
summary(glm(usuallyWatched ~ EC, data = dataset))
summary(glm(notUnderstand ~ EC, data = dataset))

summary(glm(surprised ~ EC , data = dataset[dataset$EC>3,]))
summary(glm(notInteresting ~EC, data=dataset[dataset$EC>3,]))
summary(glm(usuallyWatched ~ EC, data = dataset[dataset$EC>3,]))
summary(glm(notUnderstand ~ EC, data = dataset[dataset$EC>3,]))

summary(glm(surprised ~ EC , data = dataset[dataset$EC<=3,]))
summary(glm(notInteresting ~EC, data=dataset[dataset$EC<=3,]))
summary(glm(usuallyWatched ~ EC, data = dataset[dataset$EC<=3,]))
summary(glm(notUnderstand ~ EC, data = dataset[dataset$EC<=3,]))


summary(glm(surprised ~  diversity , data = dataset))
summary(glm(notInteresting ~  diversity , data = dataset))
summary(glm(usuallyWatched ~ diversity , data = dataset))
summary(glm(notUnderstand ~ diversity , data = dataset))


summary(glm(surprised ~  diversity , data = dataset[dataset$PC>3,]))
summary(glm(notInteresting ~  diversity , data = dataset[dataset$PC>3,]))
summary(glm(usuallyWatched ~ diversity , data = dataset[dataset$PC>3,]))
summary(glm(notUnderstand ~ diversity , data = dataset[dataset$PC>3,]))

summary(glm(surprised ~  diversity , data = dataset[dataset$EC>3,]))
summary(glm(notInteresting ~  diversity , data = dataset[dataset$EC>3,]))
summary(glm(usuallyWatched ~ diversity , data = dataset[dataset$EC>3,]))
summary(glm(notUnderstand ~ diversity , data = dataset[dataset$EC>3,]))



summary(glm(surprised ~  PC/diversity , data = dataset))
summary(glm(notInteresting ~  PC/diversity , data = dataset))
summary(glm(usuallyWatched ~  PC/diversity, data = dataset))
summary(glm(notUnderstand ~ PC/diversity , data = dataset))

summary(glm(surprised ~  PC/diversity , data = dataset[dataset$PC>3,]))
summary(glm(notInteresting ~  PC/diversity , data = dataset[dataset$PC>3,]))
summary(glm(usuallyWatched ~  PC/diversity, data = dataset[dataset$PC>3,]))
summary(glm(notUnderstand ~ PC/diversity , data = dataset[dataset$PC>3,]))

summary(glm(surprised ~  PC/diversity , data = dataset[dataset$PC<=3,]))
summary(glm(notInteresting ~  PC/diversity , data = dataset[dataset$PC<=3,]))
summary(glm(usuallyWatched ~  PC/diversity, data = dataset[dataset$PC<=3,]))
summary(glm(notUnderstand ~ PC/diversity , data = dataset[dataset$PC<=3,]))

summary(glm(surprised ~  EC/diversity , data = dataset))
summary(glm(notInteresting ~  EC/diversity , data = dataset))
summary(glm(usuallyWatched ~  EC/diversity, data = dataset))
summary(glm(notUnderstand ~ EC/diversity , data = dataset))

summary(glm(surprised ~  EC/diversity , data = dataset[dataset$EC>3,]))
summary(glm(notInteresting ~  EC/diversity , data = dataset[dataset$EC>3,]))
summary(glm(usuallyWatched ~  EC/diversity, data = dataset[dataset$EC>3,]))
summary(glm(notUnderstand ~ EC/diversity , data = dataset[dataset$EC>3,]))

summary(glm(surprised ~  EC/diversity , data = dataset[dataset$EC<=3,]))
summary(glm(notInteresting ~  EC/diversity , data = dataset[dataset$EC<=3,]))
summary(glm(usuallyWatched ~  EC/diversity, data = dataset[dataset$EC<=3,]))
summary(glm(notUnderstand ~ EC/diversity , data = dataset[dataset$EC<=3,]))


summary(glm(surprised ~  (PC/diversity)/mean_div , data = dataset))
summary(glm(notInteresting ~  (PC/diversity)/mean_div , data = dataset))
summary(glm(usuallyWatched ~  (PC/diversity)/mean_div, data = dataset))
summary(glm(notUnderstand ~ (PC/diversity)/mean_div , data = dataset))

summary(glm(surprised ~  (PC/diversity)/mean_div , data = dataset[dataset$PC>3,]))
summary(glm(notInteresting ~  (PC/diversity)/mean_div , data = dataset[dataset$PC>3,]))
summary(glm(usuallyWatched ~  (PC/diversity)/mean_div, data = dataset[dataset$PC>3,]))
summary(glm(notUnderstand ~(PC/diversity)/mean_div , data = dataset[dataset$PC>3,]))

summary(glm(surprised ~  (PC/diversity)/mean_div , data = dataset[dataset$PC<=3,]))
summary(glm(notInteresting ~  (PC/diversity)/mean_div , data = dataset[dataset$PC<=3,]))
summary(glm(usuallyWatched ~  (PC/diversity)/mean_div, data = dataset[dataset$PC<=3,]))
summary(glm(notUnderstand ~ (PC/diversity)/mean_div , data = dataset[dataset$PC<=3,]))

summary(glm(surprised ~  (EC/diversity)/mean_div , data = dataset))
summary(glm(notInteresting ~  (EC/diversity)/mean_div , data = dataset))
summary(glm(usuallyWatched ~  (EC/diversity)/mean_div, data = dataset))
summary(glm(notUnderstand ~ (EC/diversity)/mean_div , data = dataset))

summary(glm(surprised ~  (EC/diversity)/mean_div , data = dataset[dataset$EC>3,]))
summary(glm(notInteresting ~  (EC/diversity)/mean_div , data = dataset[dataset$EC>3,]))
summary(glm(usuallyWatched ~  (EC/diversity)/mean_div, data = dataset[dataset$EC>3,]))
summary(glm(notUnderstand ~ (EC/diversity)/mean_div , data = dataset[dataset$EC>3,]))

summary(glm(surprised ~  (EC/diversity)/mean_div , data = dataset[dataset$EC<=3,]))
summary(glm(notInteresting ~  (EC/diversity)/mean_div , data = dataset[dataset$EC<=3,]))
summary(glm(usuallyWatched ~  (EC/diversity)/mean_div, data = dataset[dataset$EC<=3,]))
summary(glm(notUnderstand ~ (EC/diversity)/mean_div , data = dataset[dataset$EC<=3,]))


dataset$serendipity = 0
for(i in (1:dim(dataset)[1])){
  if(mean(c(dataset$notInteresting[i],dataset$surprised[i]))>=3 && mean(c(dataset$usuallyWatched,dataset$notUnderstand))<=3){
  dataset$serendipity[i] = 1}
  else{dataset$serendipity[i] = 0}
}

summary(glm(serendipity ~  (PC/diversity)/mean_div  , data = dataset))
summary(glm(serendipity ~  (PC/diversity)/mean_div  , data = dataset[dataset$PC>3,]))
summary(glm(serendipity ~  (PC/diversity)/mean_div  , data = dataset[dataset$PC<=3,]))


summary(glm(serendipity ~  (EC/diversity)/mean_div  , data = dataset))
summary(glm(serendipity ~  (PC/diversity)/mean_div  , data = dataset[dataset$EC>3,]))
summary(glm(serendipity ~  (PC/diversity)/mean_div  , data = dataset[dataset$EC<=3,]))







##old stuff not used for paper
curiosity = data.frame(unique(data$user_id))
curiosity$PC = 0
curiosity$EC = 0
curiosity$S = 0
curiosity$D = 0
curiosity$influenceDecision = 0
curiosity$outOfScope = 0
curiosity$unexpected = 0
curiosity$usefulIdeas = 0

data.matrix(aggregate(x = data$PC, by = list(data$user_id), FUN = mean)[2]) -> curiosity$PC
data.matrix(aggregate(x = data$EC, by = list(data$user_id), FUN = mean)[2]) -> curiosity$EC
data.matrix(aggregate(x = data$influenceDecision, by = list(data$user_id), FUN = mean)[2]) ->curiosity$influenceDecision
data.matrix(aggregate(x = data$outOfScope, by = list(data$user_id), FUN = mean)[2]) ->curiosity$outOfScope
data.matrix(aggregate(x = data$unexpected, by = list(data$user_id), FUN = mean)[2]) ->curiosity$unexpected
data.matrix(aggregate(x = data$usefulIdeas, by = list(data$user_id), FUN = mean)[2]) ->curiosity$usefulIdeas
data.matrix(aggregate(x = data$S, by = list(data$user_id), FUN = mean)[2]) ->curiosity$S
data.matrix(aggregate(x = data$D, by = list(data$user_id), FUN = mean)[2]) ->curiosity$D

curiosity$S[is.na(curiosity$S)]=0
curiosity$D[is.na(curiosity$D)]=0

cor.test(curiosity$PC,curiosity$influenceDecision,method = 'spearman')
cor.test(curiosity$PC,curiosity$outOfScope,method = 'spearman')
cor.test(curiosity$PC,curiosity$unexpected,method = 'spearman')
cor.test(curiosity$PC,curiosity$usefulIdeas,method = 'spearman')

cor.test(curiosity$EC,curiosity$influenceDecision,method = 'spearman')
cor.test(curiosity$EC,curiosity$outOfScope,method = 'spearman')
cor.test(curiosity$EC,curiosity$unexpected,method = 'spearman')
cor.test(curiosity$EC,curiosity$usefulIdeas,method = 'spearman')

cor.test(curiosity$S,curiosity$influenceDecision,method = 'spearman')
cor.test(curiosity$S,curiosity$outOfScope,method = 'spearman')
cor.test(curiosity$S,curiosity$unexpected,method = 'spearman')
cor.test(curiosity$S,curiosity$usefulIdeas,method = 'spearman')

cor.test(curiosity$D,curiosity$influenceDecision,method = 'spearman')
cor.test(curiosity$D,curiosity$outOfScope,method = 'spearman')
cor.test(curiosity$D,curiosity$unexpected,method = 'spearman')
cor.test(curiosity$D,curiosity$usefulIdeas,method = 'spearman')