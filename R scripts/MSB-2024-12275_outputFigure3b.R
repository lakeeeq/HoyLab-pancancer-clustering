


library(openxlsx)
library(ComplexHeatmap)


input  <- data.frame( read.xlsx("FigureS1a/figureS1a_scaled_expression.xlsx") )

rownames(input) <- input[, 1]
input <- input[, -1]

meta <- input[, c("cellline" , "cancertype", "tissueclass"  ,
                  "mediaused" , "tissueorigin") ]
input <- input[, !colnames(input) %in%  c("cellline" , "cancertype","tissueclass"  ,
                                          "mediaused" , "tissueorigin")]


data_for_clustering <- input




col_cancertype <- c(Breast = "#FD5DFC", Colorectal = "#005f73", Endometrial = "#94CE58" ,
                    Glioblastoma = "#FED86F" , `Head and Neck` =   "#7209b7"   ,
                    Liver  = "#4DCFB0" ,  `Lung (NSC)`  = "#8ecae6" ,   Melanoma  =  "#f2cc8f" ,
                    Ovarian  =  "#F25052"  ,   Pancreatic  =   "#EC6E27" , 
                    Prostate  = "#1EB1ED"  ,   unknown   =   "#989898"    )


col_tissueclass <- c(  tumor =  "#FB8072" ,   normal = "#8DA0CB"   )    

col_tissueorigin <- c(   Prostate  =  "#1EB1ED" , Colon  = "#005f73", Breast  =  "#FD5DFC" , 
                         `Liver (human)`  =  "#984EA3"   ,   `Liver (mouse)` = "#386CB0" ,
                         Pancreas  = "#EC6E27" ,  `Central nervous system` =  "#FED86F"   ,  
                         Endometriun  =  "#94CE58"   ,  Skin  =  "#f2cc8f" ,
                         Ovary  =  "#F25052"  ,   Lung = "#8ecae6" ,   Tongue  = "#6A3D9A", 
                         Pharynx =  "#FB9A99"  )

col_mediaused = c(   `DMEM/F12` =  "#4E79A7"  ,  `DMEM HG`  = "#A0CBE8"  ,  MEM   = "#F28E2B" ,
                     RPMI = "#FFBE7D" , `phenolfree DMEM/F12`  =  "#59A14F" ,   `RPMI + 2mM L- Glutamine` = "#8CD17D" , 
                     `DMEM HG/1xGlut` = "#B6992D", `DMEM F12 + horse serum`  = "#F1CE63" ,  `RPMI + 10%CCS` =  "#499894" ,  
                     `RPMI + 10uM enzalutamide`  =  "#86BCB6"  , `Keratinocyte-SFM` = "#E15759"  , F12K  = "#FF9D9A"  )

ha = HeatmapAnnotation(
  
  tissueclass = meta$tissueclass, 
  cancertype = meta$cancertype, 
  tissueorigin = meta$tissueorigin ,  
  mediaused = meta$mediaused , 
  
  col = list(   
    cancertype = col_cancertype  ,
    tissueclass = col_tissueclass ,
    tissueorigin = col_tissueorigin , 
    mediaused = col_mediaused
    
    
  )
)



# using the same cluster groups as determined by appendix figure S1,
# based on all metabolite ratios 
order_cellline <-   c(26, 23, 8, 7, 24, 56, 12, 46, 42, 39, 44, 30, 37, 41, 48, 43, 49, 47, 22, 28,
                      13, 45, 40, 55, 15, 21, 38, 9, 54, 29, 10, 11, 36, 35, 6, 19, 27, 1, 34, 17,
                      52, 53, 33, 32, 31, 20, 25, 51, 18, 4, 3, 16, 5, 2, 14, 50, 57)

split <- c(rep(5,5 ) , rep(3 , 18) , rep(4, 11) , rep(1, 11) , rep(2, 12))

# this panel looks at cluster 3 and cluster 4 
index <- which(split %in% c(3,4))


# looks at glutamine metabolism between cluster 3 and cluster 4 
output <-   as.matrix( t(data_for_clustering ) ) [  1: 15,   order_cellline[index] ]
Heatmap(matrix =  output   , 
        top_annotation = ha[order_cellline[index]], 
        row_title_gp = gpar(fontsize = 6),
        cluster_columns = F,   cluster_rows = T, 
        clustering_distance_columns = "pearson" , 
        column_split =    split[index]   ,
        show_column_names = T) 



# write.xlsx( data.frame( output)  , "figure3b_scaled_expression.xlsx", rowNames=TRUE)


