
library(openxlsx)
library(ComplexHeatmap)


# read in batch corrected values of the cell lines 
input <- data.frame( read.xlsx("Figure1b/figure1b_input.xlsx") )

rownames(input) <- input[, 1]
input <- input[, -1]

# retrieve metadata of each cell line 
meta <- input[, c("cellline" , "cancertype", "cancer_class") ]
input <- input[, !colnames(input) %in% c("cellline" , "cancertype", "cancer_class") ]


# when there are replicate cell lines, calculate the average of the replicates 
mean_count_final <- NULL
mean_count_meta <- NULL 

for ( thiscellline in unique(meta$cellline)){
  i <- which( meta$cellline  == thiscellline)
  temp <- t(input)[ , i]
  temp <- rowMeans( as.matrix( temp  )  )
  mean_count_final <- cbind(mean_count_final, temp)
  
  temp_meta <- meta[ i[1] , ]
  mean_count_meta <- rbind(mean_count_meta,    temp_meta )
}
 
colnames(mean_count_final) <-  mean_count_meta$cellline



# specify colour of the annotation legend 
cols  <-  c("#FD5DFC",  "#005f73",  "#94CE58",  "#FED86F", 
            "#7209b7",  "#4DCFB0", "#8ecae6" , "#f2cc8f", 
            "#F25052" , "#EC6E27", "#1EB1ED" , "#989898" )
cols_cancertype <- cols
cols  <- setNames(cols  ,  c("Breast", "Colorectal",  "Endometrial","Glioblastoma" , 
                             "Head and Neck",   "Liver" ,   "Lung (NSC)", "Melanoma" , 
                             "Ovarian","Pancreatic" , "Prostate" , "unknown" ) ) 

col <- c("#FB8072" ,"#8DA0CB" )
label <- data.frame( label =  mean_count_meta$cancer_class)
col_label <- setNames(col, unique(label$label))

ha = HeatmapAnnotation(
  cancertype =  mean_count_meta$cancertype , 
  label = mean_count_meta$cancer_class  ,
  col = list( cancertype = cols  ,
              label = col_label
  )
)


# perform scaling of the metabolites 
scaled_expression <-  t( scale( t(mean_count_final) ))

Heatmap(matrix = scaled_expression    ,   top_annotation = ha, 
             row_title_gp = gpar(fontsize = 6),
             cluster_columns = T,   cluster_rows =T, 
             clustering_distance_columns = "pearson" , 
             show_column_names = T,
             column_km = 4,  column_km_repeats = 1000) 

# save the scaled expression, together with the the meta data 
scaled_expression <- data.frame( t( scaled_expression) )
scaled_expression$cancer_class <-  mean_count_meta$cancer_class
scaled_expression$cancertype <-  mean_count_meta$cancertype

# write.xlsx( scaled_expression , "figure1b_scaled_expression.xlsx",  rowNames=TRUE)
