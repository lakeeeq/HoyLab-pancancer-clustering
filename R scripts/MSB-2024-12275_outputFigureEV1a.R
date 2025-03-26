

library(ComplexHeatmap)
library(openxlsx)

# read in batch corrected metabolites value used in Figure 1b and the metadata 
input <- data.frame( read.xlsx("Figure1b/figure1b_input.xlsx")) 
meta <- data.frame( read.xlsx("Figure1c/figure1c_input.xlsx"))

meta <- meta[ match(input$cellline, meta$Var.1 ), ]
colnames(meta)[1] <- "cellline"

# clean up the metabolites names 
colnames(input) <- gsub("\\.", " ",  colnames(input))
colnames(input) <- gsub("X3PG" , "3PG",  colnames(input))
colnames(input) <- gsub(  "X6PG"  , "6PG",  colnames(input))
colnames(input) <- gsub(   "UDP GLC"  ,  "UDP-GLC"  ,  colnames(input))

rownames(input) <- input[, 1]
input <- input[, -1]

# subset to metadata of interest 
meta <- meta[, c("tissueclass" , "cancertype" , "tissueorigin" , "mediaused" ,  
                 "cellline")]
 
input <- input[, !colnames(input) %in% c("cellline" , "cancertype", "cancer_class" ) ]






# when there are replicate cell lines, compute the average 
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


data <- mean_count_final



# calculate the ratio of metabolites
# using one of the metabolites in each pathway as the anchor
tempdata <- NULL

row_split <- c()

TCA_cycle <-  c( "pyruvate" , "lactate"  , "AcCoA"  , "MalCoA", "CoA" ,"citrate" ,
                 "oxoglutarate" , "SuccCoA" ,"succinate" ,"fumarate"  , "malate"  ,
                 "NAD" ,  "NADH"  , "NADP"  ,  "NADPH"  ,"ATP" )
for (i in (2:length(TCA_cycle))){
  firstmeta <- TCA_cycle[1] #use pyruvate as the anchor 
  thismeta <- TCA_cycle[i]
  ratio <- t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "TCA_cycle")
}


Glycolysis_upper <-  c ("glucose" ,  "hexose phosphate" , "FBP" ,  "6PG",             
                        "ribose phosphate" , "S7P" ,  "E4P" , "NADP", "NADPH" )

for (i in (2:length(Glycolysis_upper))){
  firstmeta <- Glycolysis_upper[1] # use glucose as the anchor 
  thismeta <- Glycolysis_upper[i]
  ratio <- t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "Glycolysis_upper")
}


Glycolysis_upperlower <-  c ("UDP-GLC" ,  "glucose" ,  "hexose phosphate", "FBP" ,
                             "DHAP" ,"3PG" , "PEP"  ,"ATP" , "pyruvate" , "lactate" ,
                             "NADH" , "NAD" )
index <- c(1:length(Glycolysis_upperlower))
index <- index[-2]
for (i in index){
  firstmeta <- Glycolysis_upperlower[2] # use glucose as the anchor 
  thismeta <- Glycolysis_upperlower[i]
  ratio <-  t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "Glycolysis_upperlower")
}


Amino_acids <- c(  "alanine" ,   "glycine" ,   "serine" ,  "threonine" ,   
            "aspartate" , "asparagine"  , "proline" ,  "glutamate",    
            "glutamine" , "arginine" , "histidine" , "valine" ,      
            "isoleucine" , "leucine" ,"methionine" , "phenylalanine",
             "tyrosine" ,"tryptophan" , "lysine" ) 
# # there is three anchors for the amino acids   
index <- c(1:length(Amino_acids))
index <- index[-3]
for (i in index){
  firstmeta <- Amino_acids[3] # use serine as the anchor 
  thismeta <- Amino_acids[i]
  ratio <- t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "Amino_acids_serine")
}


index <- c(1:length(Amino_acids))
index <- index[-7]
for (i in index){
  firstmeta <- Amino_acids[7] # use proline as the anchor 
  thismeta <- Amino_acids[i]
  ratio <-  t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "Amino_acids_proline")
}



index <- c(1:length(Amino_acids))
index <- index[-15]
for (i in index){
  firstmeta <- Amino_acids[15] # use methoinine as the anchor 
  thismeta <- Amino_acids[i]
  ratio <-  t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "Amino_acids_methionine")
}


Glutamine_metabolism <- c( "glutamine"  ,  "glutamate",    "pyruvate" ,    "lactate" ,
                           "AcCoA"  , "CoA" , "citrate" , "oxoglutarate", "SuccCoA" ,   
                           "succinate" , "fumarate" , "malate" , "NAD" , "NADH"  ,
                           "NADP",  "NADPH" )  

for (i in (2:length( Glutamine_metabolism))){
  firstmeta <-  Glutamine_metabolism[1] # use glutamine as the anchor 
  thismeta <-  Glutamine_metabolism[i]
  ratio <-  t( as.data.frame( data[thismeta , ] / data[firstmeta, ] ) )
  rownames(ratio) <- paste0(thismeta , "_", firstmeta)
  tempdata <- rbind(tempdata, ratio)
  row_split <- c(row_split , "Glutamine_metabolism")
}


 
tempdata <- data.frame(tempdata)
remove <-  which( rownames(tempdata) %in% c("hexose.phosphate_glucose.1" , "FBP_glucose.1"  ))
tempdata <- tempdata [ -c(remove ) ,] 
row_split <- row_split[ -c(remove) ]





data_unscaled <- t(tempdata)

 
  
meta <- mean_count_meta

 
# scale the ratio of the metabolites across cell lines 
data_for_clustering <- as.data.frame( scale(data_unscaled) ) 

  
cols  <- c(Breast = "#FD5DFC", Colorectal = "#005f73", Endometrial = "#94CE58" ,
                      Glioblastoma = "#FED86F" , `Head and Neck` =   "#7209b7"   ,
                      Liver  = "#4DCFB0" ,  `Lung (NSC)`  = "#8ecae6" ,   Melanoma  =  "#f2cc8f" ,
                      Ovarian  =  "#F25052"  ,   Pancreatic  =   "#EC6E27" , 
                      Prostate  = "#1EB1ED"  ,   unknown   =   "#989898"    )

col_label <- c(  tumor =  "#FB8072" ,   normal =  "#8DA0CB" )
ha = HeatmapAnnotation(
  cancertype =  meta$cancertype, 
  label =  meta$tissueclass,
  
  col = list( cancertype = cols  ,
              label = col_label 
  ) 
)


Heatmap(matrix =   as.matrix(t(data_for_clustering ) )  ,   top_annotation = ha, 
             row_title_gp = gpar(fontsize = 6),
             cluster_columns = T,   cluster_rows = F, 
             clustering_distance_columns = "pearson" , 
             show_column_names = T,
             row_split = row_split, 
             column_km = 5, column_km_repeats = 1000) 

scaled_expression <-  cbind( data_for_clustering  , meta)

# write.xlsx( scaled_expression , "figureS1a_scaled_expression.xlsx",  rowNames=TRUE)
 
