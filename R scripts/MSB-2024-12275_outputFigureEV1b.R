

library(ComplexHeatmap)
library(openxlsx)
input <- data.frame( read_excel("FigureS1b/figureS1b_input.xlsx") )

rownames(input ) <- input[, 1]
input <- input[, -1]

meta <- input[,  c("tissueclass", "cancertype" , "tissueorigin" , "mediaused") ]

input <- input[, !colnames(input) %in% c("tissueclass", "cancertype" , 
                                         "tissueorigin" , "mediaused") ]


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

# use the same cluster groups as obtained in appendix figure S1a 
# based on the all metabolites ratios 
split <- c(rep(5,5 ) , rep(3 , 19) , rep(4, 10) , rep(1, 11) , rep(2, 12))
 
Heatmap(matrix =  t(input)  ,   top_annotation = ha, 
             row_title_gp = gpar(fontsize = 6),
             cluster_columns = F,   cluster_rows = T, 
             clustering_distance_columns = "pearson" , 
             column_split =   split  ,
             show_column_names = T) 




