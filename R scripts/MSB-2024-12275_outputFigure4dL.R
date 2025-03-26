

library(limma )
library(openxlsx)

input  <-data.frame( read.xlsx("Figure4d_left/figure4d_left_input.xlsx")) 
input[1:10, 1:10]
rownames( input) <- input[, 1]
input <- input[, -1]

cancertype <- input$cancertype
names(cancertype ) <- rownames(input)
input$cancertype <- NULL
input <- t(input)

# find cluster 3 and cluster 4 cell lines

cluster_3_cellline <- c("HT144" ,   "A375"    ,  "WM2664" ,  "Detroit562" , 
                        "SCC4"   ,   "A549"     )

cluster_4_cellline <- c( "A2780"   , "MDAMB468"  )


cluster_3_4_drug <- cbind( input[,cluster_3_cellline  ], 
                           input[,cluster_4_cellline  ])

cluster <- data.frame(cluster = c( rep("cluster3" , length(cluster_3_cellline) ), 
                                   rep("cluster4" , length(cluster_4_cellline) ))) 

design <- model.matrix(~cluster, data = cluster)
fit <- lmFit(cluster_3_4_drug , design)
fit <- eBayes(fit)

## Withtout gene symbols
library(DT)
tT <- topTable(fit, n = Inf) 
DT::datatable(round(tT[1:100, ], 2))




tT_no_same_drug <- tT
tT_no_same_drug$drug <- unlist(lapply(strsplit(rownames(tT), ".split.", fixed=T ), `[` ,1))
tT_no_same_drug <- tT_no_same_drug[!duplicated(tT_no_same_drug$drug), ]


top_drug <- rownames( tT_no_same_drug[1:20, ] )


top_drug_df  <- input[ top_drug , c(cluster_3_cellline , cluster_4_cellline ) ]



cols <- c(Breast = "#FD5DFC", Colorectal = "#005f73", Endometrial = "#94CE58" ,
          Glioblastoma = "#FED86F" , `Head and Neck` =   "#7209b7"   ,
          Liver  = "#4DCFB0" ,  `Lung (NSC)`  = "#8ecae6" ,   Melanoma  =  "#f2cc8f" ,
          Ovarian  =  "#F25052"  ,   Pancreatic  =   "#EC6E27" , 
          Prostate  = "#1EB1ED"  ,   unknown   =   "#989898"    )
ha = HeatmapAnnotation(
  cancertype = cancertype[ c(cluster_3_cellline , cluster_4_cellline ) ]  , 
  col = list( cancertype = cols  
  )
)



input <-  t(scale(t(top_drug_df )))

input <- apply(input, 2, rescale, to=c(-4,4))

Heatmap(matrix =   as.matrix(  input )   ,   top_annotation = ha, 
        row_title_gp = gpar(fontsize = 6),
        cluster_columns = F,   cluster_rows = T,  
        clustering_distance_columns = "pearson" , 
        show_column_names = T,
        column_split =    c(rep(3, length(cluster_3_cellline)), rep(4, length(cluster_4_cellline) ) ) ,
        row_names_gp = gpar(fontsize = 15), column_km_repeats = 1000) 


# write.xlsx( data.frame(input), "figure4d_left_scaled_fitness.xlsx", rowNames=TRUE)




