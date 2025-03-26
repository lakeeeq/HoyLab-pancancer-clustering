


library(openxlsx)
library(dplyr)
library(pheatmap)

input  <- data.frame( read.xlsx("FigureS3c/FigureS3c_input.xlsx")) 

# only interested in the sensitive pathways for cluster 4 cell lines 
input <- input[input$logFC < 0, ]

# select the top 20 pathways in each dataset
top_rows_by_dataset <- input %>% group_by(dataset) %>% 
  slice(1:20) %>%  ungroup()



pathway_all_df <- top_rows_by_dataset
# counting how many times each combination of dataset and pathway occurs 
pathway_all_df_count <- pathway_all_df %>% dplyr::group_by(dataset, pathway) %>%
  dplyr::summarise(n = n())
pathway_all_df_count <- pathway_all_df_count %>% 
  tidyr::pivot_wider(names_from = "dataset" , values_from = "n")
pathway_all_df_count <- as.data.frame(pathway_all_df_count )
rownames(pathway_all_df_count) <- pathway_all_df_count$pathway
pathway_all_df_count <- pathway_all_df_count[ , -1]
# if a pathway has not appeared in a datast, make it 0
pathway_all_df_count[is.na(pathway_all_df_count)] <- 0


pathway_all_df_unique <-  pathway_all_df %>% distinct()
# order the pathway by how many times they appear 
pathway_order <- names( sort ( table(pathway_all_df_unique$pathway) , decreasing = T) ) 
pathway_all_df_count <- pathway_all_df_count[pathway_order,  ]
rownames( pathway_all_df_count )  <- stringr::str_to_sentence( rownames( pathway_all_df_count ) )  
 

print( pheatmap::pheatmap(pathway_all_df_count , 
                          display_numbers = pathway_all_df_count ,
                          number_color = "black", 
                          cluster_rows = F) ) 


 


