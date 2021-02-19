#Clustering k-means 
#Calidad Estadística

library(ggplot2)
library(factoextra)
library(NbClust)
library(cluster)
library(dplyr)
library(tidyr)

stats_cap <- read.csv("C:/Users/Carolina/Desktop/Clusters/Capacidad Estadistica.csv",
                      header = TRUE, sep = ";",
                      row.names = 1, col.names = c("Evaluación fuente",
                                                   "Evaluación metodología", 
                                                   "Evaluación periodicidad"))

#Calculando y graficando la matriz de distancia
stats_cap <- scale(stats_cap) 

dist_stats <- get_dist(stats_cap, "euclidean") #factoextra
fviz_dist(dist_stats, gradient = list(low = "blue", mid = "white", high = "red"),
          lab_size = 5) #factoextra

#Determinando un número de clusters óptimo
clustop <- kmeans(stats_cap, centers = 1)$betweenss

for(i in 2:10) clustop[i] <- kmeans(stats_cap, centers = i)$betweenss

plot(1:10, clustop, type = "b", main = "Optimal Number of Clusters",
     xlab = "Number of clusters", ylab = "Total Within Sum of Square", 
     pch = 16, col = "#2E9FDF")

set.seed(123)
allclusterstats <- NbClust(stats_cap, distance = "euclidean", min.nc = 2, max.nc = 10,
                           method = "kmeans", index = "alllong") #nbclust

fviz_nbclust(allclusterstats)

#Calculando k = 3, k = 2
set.seed(123)
clust_3 <- kmeans(stats_cap, centers = 3, nstart = 50)

clust_2 <- kmeans(stats_cap, centers = 2, nstart = 50)

#Test silhoutte
test <- silhouette(clust_3$cluster, dist(stats_cap))
fviz_silhouette(test, palette = c("#2E9FDF", "green4","indianred2"))

#Grafica de conglomerados
p1 <- fviz_cluster(clust_3, stats_cap, show.clust.cent = TRUE, ellipse.type = "convex", 
             repel = T, main = "Cluster Plot - Statistical Quality k = 3",
             palette = c("#2E9FDF","green4","indianred2"),
             geom = c("point", "text"), labelsize = 7, 
             ggtheme = theme_minimal() +
             theme(plot.title = element_text(hjust = 0.5)))

p2 <- fviz_cluster(clust_2, stats_cap, show.clust.cent = TRUE, ellipse.type = "convex", 
             repel = T, main = "Cluster Plot - Statistical Quality k = 2",
             palette = c("green4","indianred2"),
             geom = c("point", "text"), labelsize = 7, 
             ggtheme = theme_minimal() +
               theme(plot.title = element_text(hjust = 0.5)))

#Dendograma
dend3 <- hcut(stats_cap, k = 3, stand = T)
fviz_dend(dend3, rect = T, cex = 0.5, k_colors = c("indianred2", "#2E9FDF", "green4"),
          ggtheme = theme_classic()+
            theme(plot.title = element_text(hjust = 0.5)))

#Gráficas de distribución de conglomerados
stats_cap <- as.data.frame(stats_cap)
stats_cap %>%
  mutate(Cluster = clust_3$cluster)%>%
  group_by(Cluster)%>%
  summarise_all("mean")

stats_cap <- scale(stats_cap)
stats_cap <- as.data.frame(stats_cap)
stats_cap$clus <- as.factor(clust_3$cluster)

stats_cap$clus <- factor(stats_cap$clus)
data_modification <- gather(stats_cap, variable, value, Evaluación.fuente: 
                              Evaluación.periodicidad, factor_key = TRUE)

cd <- ggplot(data_modification, aes(as.factor(x = variable), 
                                    y = value, group = clus,
                                    colour = clus))+
  stat_summary(fun = mean, geom = "pointrange", size = 1, aes(shape = clus)) +
  stat_summary(geom = "line") + labs (x = NULL) +
  geom_point(aes(shape = clus))+
  theme_minimal()

cd + scale_color_manual(values=c("#2E9FDF", "green4", "indianred2"))
