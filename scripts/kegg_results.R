# load libraries
library(tidyverse)

# create functions
load_kegg <- function(x){
    df <- read.table(x, col.names = "KEGG") %>% group_by(KEGG) %>%
        summarise(n = n())
    df$acc <- str_match(x, pattern = "/([A-Za-z0-9._]+)_keggid.txt")[,2]
    df
    }

example_data <- function(x=FALSE, n=100){
    base <- c(rep(0,10),1:10)
    sample(base, n,replace = T)
    }

fls <- list.files("/hps/research/finn/escameron/checkm2/universal_testing/kegg_counts/", full.names = T, pattern = "*_keggid.txt")

df_test <- lapply(fls, load_kegg) %>% bind_rows()


M_test <- df_test %>% spread(KEGG, n, fill = 0)



df_cyano = t(sapply(1:50, example_data)) %>% as_tibble()
df_cyano$completeness = 1.0

M_cyano$acc <- NULL
completeness <- rep(1.0, nrow(M_cyano))

M_cyano_v2 <- cbind(completeness, M_cyano)

M_cyano_v2 <- M_cyano_v2[, colnames(M_cyano_v2) %in% colnames(sim_data)]

missing_cols_cyano <- colnames(sim_data)[!colnames(sim_data) %in% colnames(M_cyano_v2)]

for (i in seq_along(missing_cols_cyano)){
    M_cyano_v2[[missing_cols_cyano[i]]] <- 0
    }

M_cyano_v2 <- M_cyano_v2[, colnames(sim_data)]
