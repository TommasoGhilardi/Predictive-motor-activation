
# Library ---------------------------------------------------------------
library(lme4)
library(lmerTest)
library(modelbased)

library(fitdistrplus)
library(performance)

library(ggplot2)
library(ggthemes)


# Preparing Palette and Theme --------------------------------------------------------------------

Palette1<- c("#a00000","#dc2c25","#f35c40")
PaletteB = c("#780000","#C1121f","#BC4B51" )

My_Theme = theme(
  panel.background = element_rect(fill = 'white', colour = 'black'),
  axis.title.x = element_text(size = 20,face = "bold"),
  axis.text.x = element_text(size = 18, color= "black"),
  axis.text.y = element_text(size = 18, color= "black"),
  axis.title.y = element_text(size = 20, face = "bold"),
  legend.text = element_text(size = 20),
  legend.title = element_text(size = 20, face = "bold"))

# Directories-------------------------------------------------------------

data_location <- "C:\\Users\\krav\\surfdrive\\Projects\\AdultsEEG\\Analysis\\"

plot_exporting <- "C:\\Users\\krav\\surfdrive\\Projects\\AdultsEEG\\Analysis\\figures\\"


# Import data -------------------------------------------------------------

db <- read.csv(file=paste(data_location,"Single_Channel_Clean_prediction.csv",sep=''),
               header=TRUE, sep=",")

colnames(db)[2] <- 'Level'
db<- db[db['Frequency']=='mu',]

db['Probability']<-db['Level']
db['Surprise']<-db['Level']
db['Entropy']<-db['Level']

### Setting the appropriate levels 

db[db$Level==0,]$Probability=0
db[db$Level==1,]$Probability=25
db[db$Level==2,]$Probability=50
db[db$Level==3,]$Probability=50
db[db$Level==4,]$Probability=75
db[db$Level==5,]$Probability=75
db[db$Level==6,]$Probability=100

db[db$Level==0,]$Surprise=-2.5
db[db$Level==1,]$Surprise=-2
db[db$Level==2,]$Surprise=-1
db[db$Level==3,]$Surprise=-1
db[db$Level==4,]$Surprise=-0.4
db[db$Level==5,]$Surprise=-0.4
db[db$Level==6,]$Surprise=-0

db[db$Level==0,]$Entropy=-2.58
db[db$Level==1,]$Entropy=-2.25
db[db$Level==2,]$Entropy=-1.50
db[db$Level==3,]$Entropy=-1
db[db$Level==4,]$Entropy=-1
db[db$Level==5,]$Entropy=-0.81
db[db$Level==6,]$Entropy=-0

summary(db) #check the dataframe




# ANOVA Probability -------------------------------------------------------------------

Anova_prob<- db[ db$Area != 'O1'& db$Area != 'O2' & db$Area != 'Oz',]
Anova_prob[['Probability']]<-factor(Anova_prob[['Probability']])
Anova_prob[['Surprise']]<-factor(Anova_prob[['Surprise']])

summary(Anova_prob)  #check the data

### Distribution
descdist(Anova_prob$Power, discrete = FALSE)
plot(fitdist(Anova_prob$Power, "norm"))

### The model
Anova_prob.aov<- lmer(Power ~ Probability  +(1|Subject/Area),data=Anova_prob)
summary(Anova_prob.aov)

### Check assumptions
check_model(Anova_prob.aov)

anova(Anova_prob.aov)
estimate_contrasts(Anova_prob.aov, adjust = "Bonferroni")

### Plot
Anova_prob.p <- ggplot(Anova_prob, aes(Surprise, Power)) +
  stat_summary(fun = mean, geom = "bar",colour='black' ,fill = Palette1[1],width=0.5, alpha =seq(1, 0.4, by=-0.15))+
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2)+
  labs(title="Probability - Motor Area",x="\nProbability",y="\nMu log(Power)\n")+
  geom_hline(yintercept=-0.15)+coord_cartesian(xlim=c(-0.05,5.5),ylim=c(-0.43,-0.15),expand = FALSE)+
  theme(legend.position = "none")+My_Theme+
  scale_x_discrete(labels=c("100%","75%","50%","25%","Baseline"))
  
Anova_prob.p
ggsave(paste(plot_exporting,"Anova_Probability_mu.png",sep=''),
       width = 28, height = 28, units = "cm", dpi="retina")




# Anova Entropy -----------------------------------------------------------
Anova_entro <- db[db$Level != 0 & db$Level != 1 & db$Level != 6 & 
              db$Area != 'O1'& db$Area != 'O2' & db$Area != 'Oz',]

Anova_entro[Anova_entro$Level==2,]$Entropy='Low'
Anova_entro[Anova_entro$Level==3,]$Entropy='High'
Anova_entro[Anova_entro$Level==4,]$Entropy='Low'
Anova_entro[Anova_entro$Level==5,]$Entropy='High'

Anova_entro[Anova_entro$Level==2,]$Probability='50%'
Anova_entro[Anova_entro$Level==3,]$Probability='50%'
Anova_entro[Anova_entro$Level==4,]$Probability='75%'
Anova_entro[Anova_entro$Level==5,]$Probability='75%'

summary(Anova_entro) #check the data

#### Check distribution
descdist(Anova_entro$Power, discrete = FALSE)
plot(fitdist(Anova_entro$Power, "norm"))

### The model
Anova_entro.aov<-lmer(Power ~ Entropy * Probability +(1|Subject/Area), 
                      control=lmerControl(optimizer="bobyqa",optCtrl=list(maxfun=2e5)),data = Anova_entro)
summary(Anova_entro.aov)

### Check assumptions
check_model(Anova_entro.aov)

anova(Anova_entro.aov)

### Plot
Anova_entro.p <- ggplot(Anova_entro, aes(Probability, Power)) +
  stat_summary(fun = mean, geom = "bar", color = "black",
               width=0.4,position =position_dodge(),aes(fill = factor(Entropy, levels=c("Low","High"))))+
  stat_summary(fun.data = mean_se, geom = "errorbar",
               position=position_dodge(.4),width = 0.1,aes(group= factor(Entropy, levels=c("Low","High"))))+
  geom_hline(yintercept=-0.15)+ coord_cartesian(xlim=c(0.4,2.3),ylim=c(-0.43,-0.15),expand = FALSE)+
  My_Theme+ scale_fill_manual("Predictability", values = c("High" = Palette1[2], "Low" = Palette1[1]))+
  labs(title="Expectancy x Predictability Interaction - Motor Area",x="\nExpectancy",y="Mu log(Power)\n", fill="Predictability")

Anova_entro.p
ggsave(paste(plot_exporting,"Anova_Entropy_mu.png",sep=''),
       width = 28, height = 28, units = "cm", dpi="retina")




# Linear Mixed Models ----------------------------------------------------------

Comparison = db[(db$Area != 'O1'& db$Area != 'O2' & db$Area != 'Oz' & db$Level!=0),]

#### Check distribution
descdist(Comparison$Power, discrete = FALSE)
plot(fitdist(Comparison$Power, "norm"))


### Null model
Comparison.baseline <- lmer(Power ~ 1 +(1|Subject/Area),data=Comparison, REML = FALSE)
summary(Comparison.baseline)


### Surprise model
Comparison.surp <-lmer(Power ~ Surprise +(1|Subject/Area),data=Comparison, REML = FALSE)
check_model(Comparison.surp) #Check assumptions

summary(Comparison.surp)

### Entropy model
Comparison.entro <-lmer(Power ~ Entropy +(1|Subject/Area),data=Comparison, REML = FALSE)
check_model(Comparison.entro) #Check assumptions

summary(Comparison.entro)


######  Comparison of the Linear Mixed Models 
Compa_tot<-compare_performance(Comparison.baseline,Comparison.surp,Comparison.entro)
Compa_tot
plot(Compa_tot)+theme(axis.text=element_text(size=15), legend.title = element_text(color = "black", size = 25),
                      legend.text = element_text(color = "black", size = 17),legend.position = c(1.05, 0.8))+
  scale_color_manual(name="MODELS",
                     labels=c("Expectancy","Null","Predictability"),
                     values=c("red","green","blue"))

ggsave(paste(plot_exporting,"Models_comaprison_mu.png",sep=''),
      width = 12, height = 10, units = "in", dpi = 300)


### Barplot AIC
aic<-AIC(Comparison.baseline,Comparison.surp,Comparison.entro)
aic$Models = rownames(aic)

ggplot(aic, aes( x= reorder(Models, AIC),y=AIC))+
  geom_bar(stat='identity',fill = PaletteB)+
  geom_text(aes(label=round(AIC,2)),
            size=6 ,position=position_dodge(width=0.9), vjust=-1.5)+
  coord_cartesian(ylim=c(18220,18233)) + My_Theme+
  labs(title="AIC comparison\n", x= "\nModels")+
  scale_x_discrete(labels=c("Null","Expectancy","Predictability"))

ggsave(paste(plot_exporting,"AIC_mu.png",sep=''),
       width = 25, height = 28, units = "cm", dpi = 300)





# OCCIPITAL area analysis -------------------------------------------------------------------

### Anova probability

Anova_prob_occ<- db[ db$Area != 'C3'& db$Area != 'C4' & db$Area != 'Cz',]
Anova_prob_occ[['Probability']]<-factor(Anova_prob_occ[['Probability']])
Anova_prob_occ[['Surprise']]<-factor(Anova_prob_occ[['Surprise']])

summary(Anova_prob_occ)

### Distribution
descdist(Anova_prob_occ$Power, discrete = FALSE)
plot(fitdist(Anova_prob_occ$Power, "norm"))

### The model
Anova_prob_occ.aov<- lmer(Power ~ Probability  +(1|Subject/Area),data=Anova_prob_occ)
summary(Anova_prob_occ.aov)

### Check assumptions
check_model(Anova_prob_occ.aov) 

anova(Anova_prob_occ.aov) # F-test on the linear model
estimate_contrasts(Anova_prob_occ.aov, adjust = "Bonferroni")


### Plot
Anova_prob_occ.p <- ggplot(Anova_prob_occ, aes(Probability, Power)) +
  stat_summary(fun = mean, geom = "bar",colour='black' ,fill = Palette1[1],width=0.5, alpha =seq(0.40, 1, by=0.15))+
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2)+
  labs(title="Probability - Occipital Area",x="\nProbability",y="Mu log(Power)\n")+
  geom_hline(yintercept=-0.025)+ coord_cartesian(xlim=c(0.4,5.5),ylim=c(-0.12,-0.025),expand = FALSE)+ 
  My_Theme+ theme(legend.position = "none")+
  scale_x_discrete(limits = rev(levels(Anova_prob_occ$Probability)),labels=c("100%","75%","50%","25%","Baseline"))  
                   
Anova_prob_occ.p
ggsave(paste(plot_exporting,"Anova_Probability_mu_occipital.png",sep=''),
       width = 28, height = 28, units = "cm", dpi="retina")





