
# Library ----------------------------------------------------------------------
library(lme4)
library(lmerTest)
library(modelbased)
library(fitdistrplus)
library(performance)
library(sjPlot)

library(ggplot2)
library(ggthemes)

# Preparing Palette and Theme --------------------------------------------------------------------

Palette1 = c("#3f6d9b", "#6e8dab", "#cccccc")
PaletteB = c("#13293d","#1B98E0","#247BA0", "#AFCBFF")

My_Theme = theme(
  panel.background = element_rect(fill = 'white', colour = 'black'),
  axis.title.x = element_text(size = 20,face = "bold"),
  axis.text.x = element_text(size = 18, color= "black"),
  axis.text.y = element_text(size = 18, color= "black"),
  axis.title.y = element_text(size = 20, face = "bold"),
  legend.text = element_text(size = 20),
  legend.title = element_text(size = 20, face = "bold"))



# Directories -------------------------------------------------------------------

data_location <- "C:\\Users\\krav\\surfdrive\\Projects\\AdultsEEG\\Analysis\\"

plot_exporting <- "C:\\Users\\krav\\surfdrive\\Projects\\AdultsEEG\\Analysis\\figures\\"




# Import data ------------------------------------------------------------------

db <- read.csv(file=paste(data_location,"Single_Channel_Clean_prediction.csv",sep=''),
               header=TRUE, sep=",")

colnames(db)[2] <- 'Level'
db<- db[db['Frequency']=='beta',]

db['Probability']<-db['Level']
db['Surprise']<-db['Level']
db['Entropy']<-db['Level']
db['Exploratory']<-db['Level']

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

db[db$Level==0,]$Exploratory=-2.5
db[db$Level==1,]$Exploratory=-1.5
db[db$Level==2,]$Exploratory=-0.5
db[db$Level==3,]$Exploratory=-1
db[db$Level==4,]$Exploratory=-0.3
db[db$Level==5,]$Exploratory=-0.3
db[db$Level==6,]$Exploratory=-0


summary(db) #check the dataframe




# ANOVA Probability ------------------------------------------------------------

Anova_prob<- db[ db$Area != 'O1'& db$Area != 'O2' & db$Area != 'Oz',]
Anova_prob[['Probability']]<-factor(Anova_prob[['Probability']])
Anova_prob[['Surprise']]<-factor(Anova_prob[['Surprise']])

summary(Anova_prob) #check the data

#### Check distribution
descdist(Anova_prob$Power, discrete = FALSE)
plot(fitdist(Anova_prob$Power, "norm"))

### The model
Anova_prob.aov<- lmer(Power ~ Probability  +(1|Subject/Area),data=Anova_prob)
summary(Anova_prob.aov)

#### Checking assumptions
check_model(Anova_prob.aov )

anova(Anova_prob.aov) # F-test on the linear model
estimate_contrasts(Anova_prob.aov, adjust = "Bonferroni")


#### Plot
Anova_prob.p <- ggplot(Anova_prob, aes(Surprise, Power)) +
  stat_summary(fun = mean, geom = "bar",colour='black' ,fill = Palette1[1],width=0.5, alpha =seq(1, 0.4, by=-0.15))+
  stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.2)+
  labs(title="Probability - Motor Area",x="\nProbability",y="Beta log(Power)\n")+
  coord_cartesian(xlim=c(-0.05,5.5),ylim=c(-0.86,-0.6),expand = FALSE)+
  geom_hline(yintercept=-0.6)+
  My_Theme + theme(legend.position = "none")+
  scale_x_discrete(labels=c("100%","75%","50%","25%","Baseline"))

Anova_prob.p
ggsave(paste(plot_exporting,"Anova_Probability_beta.png",sep=''),
       width = 28, height = 28, units = "cm", dpi="retina")




# Anova Entropy ----------------------------------------------------------------

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

#### Checking assumptions
check_model(Anova_entro.aov )

anova(Anova_entro.aov) # F-test on the linear model
estimate_contrasts(Anova_entro.aov,contrast = c("Probability", "Entropy"), adjust = "Bonferroni")


#### Plot
Anova_entro.p <- ggplot(Anova_entro, aes(Probability, Power)) +
  stat_summary(fun = mean, geom = "bar", color = "black",
               width=0.4,position =position_dodge(),aes(fill = factor(Entropy, levels=c("Low","High"))))+
  stat_summary(fun.data = mean_se, geom = "errorbar",
               position=position_dodge(.4),width = 0.1,aes(group= factor(Entropy, levels=c("Low","High"))))+
  coord_cartesian(xlim=c(0.4,2.3),ylim=c(-0.86,-0.6),expand = FALSE)+
  geom_hline(yintercept=-0.6)+ 
  My_Theme+ scale_fill_manual("Predictability", values = c("High" = Palette1[2], "Low" = Palette1[1]))+
  labs(title="Expectancy x Predictability Interaction - Motor Area",x="\nExpectancy",y="Beta log(Power)\n", fill="Predictability")

Anova_entro.p
ggsave(paste(plot_exporting,"Anova_Entropy_beta.png",sep=''),
       width = 28, height = 28, units = "cm", dpi="retina")




# Linear Mixed Models ----------------------------------------------------------

Comparison = db[(db$Area != 'O1'& db$Area != 'O2' & db$Area != 'Oz' & db$Level!=0),]

#### Check the distribution 
descdist(Comparison$Power, discrete = FALSE)
plot(fitdist(Comparison$Power, "norm"))


### Null model 
Null_Model <- lmer(Power ~ 1 +(1|Subject/Area),data=Comparison, REML = FALSE)
summary(Null_Model)


### Surprise model
Expectancy_Model <-lmer(Power ~ Surprise +(1|Subject/Area),data=Comparison, REML = FALSE)
check_model(Expectancy_Model) #Check assumptions

summary(Expectancy_Model)


### Entropy model
Predictability_Model <-lmer(Power ~ Entropy +(1|Subject/Area),data=Comparison, REML = FALSE)
check_model(Predictability_Model) #Check assumptions

summary(Predictability_Model)



######  Comparison of the Linear Mixed Models 
Compa_tot = compare_performance(Null_Model,Expectancy_Model,Predictability_Model, metrics =c("AIC", "ICC","R2", "RMSE"))
Compa_tot

plot(Compa_tot, size=2)+theme(axis.text=element_text(size=15), legend.title = element_text(color = "black", size = 25),
                      legend.text = element_text(color = "black", size = 17),legend.position = c(1.05, 0.8))+
  scale_color_manual(name="MODELS",
                     labels=c("Expectancy","Null","Predictability"),
                     values=c("#247BA0","#13293d","#1B98E0"))

ggsave(paste(plot_exporting,"Models_comaprison_beta.png",sep=''),
       width = 50, height = 28, units = "cm", dpi = 300)

####  Barplot AIC
aic<-AIC(Null_Model,Expectancy_Model,Predictability_Model)
aic$Models = rownames(aic) 

ggplot(aic, aes( x= reorder(Models, -AIC),y=AIC))+
  geom_bar(stat='identity',fill = PaletteB)+
  geom_text(aes(label=round(AIC,2)),
            size=6 ,position=position_dodge(width=0.9), vjust=-1.5)+
  coord_cartesian(ylim=c(17410,17435)) + My_Theme+
  labs(title="AIC comparison\n", x= "\nModels")+
  scale_x_discrete(labels=c("Null","Predictability","Expectancy"))

ggsave(paste(plot_exporting,"AIC_beta.png",sep=''),
       width = 25, height = 28, units = "cm", dpi = 300)

### Difference AIC

Delta.Null_EXP =  aic$AIC[1] - aic$AIC[2]
Delta.Null_Pre =   aic$AIC[1] - aic$AIC[3]
Delta.EXP_Pre  =   aic$AIC[3] - aic$AIC[2]




# Exploratory model ------------------------------------------------------------

Exploratory_Model <-lmer(Power ~ Exploratory +(1|Subject/Area),data=Comparison, REML = FALSE)
check_model(Exploratory_Model) #Check assumptions

summary(Exploratory_Model)


######  Comparison including the exploratory model
Compa_exp = compare_performance(Null_Model,Expectancy_Model,Predictability_Model,Exploratory_Model,metrics =c("AIC", "ICC","R2", "RMSE"))
Compa_exp

plot(Compa_exp, size=3)+theme(axis.text=element_text(size=30),legend.position = "none")+
  scale_color_manual(name="MODELS",
                     labels=c("Expectancy","Exploratory","Null","Predictability"),
                     values=c("#1B98E0","#AFCBFF","#13293d","#247BA0"))

ggsave(paste(plot_exporting,"SpyderPlotBeta.png",sep=''),
       width = 35, height = 35,units = "cm", dpi = 300)


####  Barplot AIC
aic_adj = AIC(Null_Model,Expectancy_Model,Predictability_Model,Exploratory_Model)
aic_adj$Models = rownames(aic_adj) 

ggplot(aic_adj, aes( x= reorder(Models, -AIC),y=AIC))+
  geom_bar(stat='identity',fill = PaletteB)+
  geom_text(aes(label=round(AIC,2)),
            size=6 ,position=position_dodge(width=0.9), vjust=-1.5)+
  coord_cartesian(ylim=c(17410,17435)) + My_Theme+
  labs(title="AIC comparison\n", x= "\nModels")+
  scale_x_discrete(labels=c("Null","Predictability","Expectancy", "Exploratory"))

ggsave(paste(plot_exporting,"AIC_beta_adj.png",sep=''),
       width = 25, height = 28, units = "cm", dpi = 300)

Delta.Adj_Null =  aic_adj$AIC[4] - aic_adj$AIC[1]
Delta.Adj_Pre  =  aic_adj$AIC[4] - aic_adj$AIC[3]
Delta.Adj_Exp  =  aic_adj$AIC[4] - aic_adj$AIC[2]















