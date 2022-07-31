rm(list=ls())
#Package Install and Load
suppressMessages({
  if(!require("pacman")) install.packages("pacman")
  pacman::p_load("ggplot2","tibble","dplyr","gridExtra","Lock5Data","ggthemes",
                 "maps","mapproj","corrplot","fun","zoo", "purrr","ggrepel")
  })

#Set path working directory
setwd("C:/Users/Joaquin/Desktop/UdeSA/Maestría en Economía/Herramientas Computacionales Para Investigación/Data Visualization (R)/Tarea-5")
#Check working directory
getwd()

#Note: Working directory should be "Beginning-Data-Visualization-with-ggplot2-and-R"

#Load the data files
url<-"https://raw.githubusercontent.com/TrainingByPackt/Applied-Data-Visualization-with-R-and-ggplot2/master/"
df <- read.csv(paste0(url,"data/gapminder-data.csv"))
df2 <- read.csv(paste0(url,"data/xAPI-Edu-Data.csv"))
df3 <- read.csv(paste0(url,"data/LoanStats.csv"))


#Summary of the three datasets
str(df)
str(df2)
str(df3)


#First Graph
#data
dfn <- subset(HollywoodMovies2013, Genre %in% c("Action","Adventure","Comedy","Drama","Romance")
              & LeadStudio %in% c("Fox","Sony","Columbia","Paramount","Disney"))
#original plot
p2<- ggplot(dfn,aes(Genre,WorldGross)) +
        geom_bar(stat="Identity",aes(fill=LeadStudio),position="dodge")+
        theme(axis.title.x=element_text(size=15),
           axis.title.y=element_text(size=15),
           plot.background=element_rect(fill="gray87"),
           panel.background = element_rect(fill="beige"),
           panel.grid.major = element_line(color="Gray",linetype=1))
ggsave(filename="Outputs/original1.png",plot=p2,width=16, height=10,units = "cm")

#new data (for labels)
dfn2<-dfn%>%group_by(LeadStudio,Genre)%>%summarise(WorldGross=sum(WorldGross,na.rm=T))
#changed plots
p2prime<- ggplot(dfn2,aes(x=reorder(Genre,WorldGross),y=WorldGross,fill=LeadStudio,label = round(WorldGross))) +
  geom_bar(stat="Identity",position="stack")+
  geom_text_repel(size = 3, position =position_stack(vjust =0.2))+
  theme_minimal()+
  coord_flip()+
  scale_fill_brewer(palette="Set3")+
  labs(y = "World Gross", x = "Genre",
       title = "Hollywood Movies by Gender 2013",
       fill="Lead Studio"
       )+
  theme(legend.position = c(0.7, 0.5),
        panel.grid = element_blank())
ggsave(filename="Outputs/changed1.png",plot=p2prime,width=16, height=10,units = "cm")


#Second Graph - Europe
#data
europe <- map_data("world", region=c("Germany", "Spain", "Italy","France","UK","Ireland")) 
#original plot
europeoriginal<-ggplot(europe, aes(x=long, y=lat, group=group, fill=region)) +
  geom_polygon(colour="black")+
  scale_fill_brewer(palette="Set3")
ggsave(filename="Outputs/original2.png",plot=europeoriginal,width=16, height=10,units = "cm")

#centroids
centroids <- europe %>% group_by(region) %>%
  summarize_at(vars(long, lat), ~ mean(range(.)))
#new plot
europeprime<-ggplot(europe, aes(x=long, y=lat, fill=region)) +
  geom_polygon(aes(group=group),colour="black")+
  coord_map("gilbert")+
  scale_fill_brewer(palette="Set3")+
  geom_text(data=centroids,aes(label = region, x = long, y = lat),
            position=position_jitter(),color="black")+
  theme_minimal()+
  labs(y = "Latitude", x = "Longitude",
       title = "Europe",
       subtitle = "Country Subselection"
  )+ guides(fill="none", color="none")
ggsave(filename="Outputs/changed2.png",plot=europeprime,width=16, height=10,units = "cm")


#Third Graph
#data (less than original, less facets)
dfprime<-df%>%filter(! Country %in% c("India","China","Japan"))pd4original <- ggplot(dfprime,aes(x=BMI_male,y=BMI_female))+
  geom_point(aes(color=Country),size=2)+
  scale_colour_brewer(palette="Dark2")+theme(axis.title=element_text(size=15,color="cadetblue4",
                                                                     face="bold"),
                                             plot.title=element_text(color="cadetblue4",size=18,
                                                                     face="bold.italic"),
                                             panel.background = element_rect(fill="azure",color="black"),
                                             panel.grid=element_blank(),
                                             legend.position="bottom",
                                             legend.justification="left",
                                             legend.title = element_blank(),
                                             legend.key = element_rect(color=3,fill="gray97")
  )+
  xlab("BMI Male")+
  ylab("BMI female")+
  ggtitle("BMI female vs BMI Male")
ggsave(filename="Outputs/original3.png",plot=pd4original,width=16, height=10,units = "cm")

#new plot
pd4prime <- ggplot(dfprime,aes(x=BMI_male,y=BMI_female))+
  geom_point(data=select(dfprime,-Country), colour="grey")+
  geom_point(aes(colour=factor(Country)),size=2)+
  facet_wrap(~Country, scale="free") +
  xlab("BMI Male")+
  ylab("BMI female")+
  ggtitle("BMI female vs BMI Male")+
  theme_minimal()+
  labs(y = "BMI female", x = "BMI Male",
       title = "BMI female vs BMI Male",
       subtitle = "by Country"
  )+ guides(fill="none", color="none") 
ggsave(filename="Outputs/changed3.png",plot=pd4prime,width=16, height=10,units = "cm")

