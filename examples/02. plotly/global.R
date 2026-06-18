# --- Packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(data.table)
library(plotly)
library(ggplot2)
library(scales)
library(viridisLite)

# --- Source modules and helpers ----------------------------------------------
source("R/utils_plotly_theme.R")
source("R/mod_manhattan.R")
source("R/mod_proxy.R")
source("R/mod_ggplotly.R")
source("R/mod_linked.R")
source("R/mod_semantic_zoom.R")

# --- Load GWAS data ----------------------------------------------------------
# data.table::fread is ~10x faster than read.csv for this 10M-row file
message("Loading GWAS data...")
gwas <- fread("gwas_data.csv")
message("Loaded ", format(nrow(gwas), big.mark = ","), " rows")

# --- Pre-compute genomic coordinates ----------------------------------------
# Manhattan plots use a cumulative x-axis so chromosomes sit side by side.
# We compute this once at startup, not per-request.

chr_info <- gwas[, .(
  chr_len = max(pos)
), by = chr][order(chr)]

chr_info[, cum_start := cumsum(shift(chr_len, fill = 0))]

# Merge cumulative offset back and compute genomic position
gwas <- merge(gwas, chr_info[, .(chr, cum_start)], by = "chr")
gwas[, bp_cum := pos + cum_start]

# --- Pre-compute -log10(p) ---------------------------------------------------
gwas[, neglog10p := -log10(pvalue)]

# --- Chromosome axis tick positions (midpoint of each chr) -------------------
chr_ticks <- gwas[, .(center = (min(bp_cum) + max(bp_cum)) / 2), by = chr]
setorder(chr_ticks, chr)

# --- Significance thresholds -------------------------------------------------
GENOME_WIDE_SIG <- -log10(5e-8)   # 7.3
SUGGESTIVE_SIG  <- -log10(1e-5)   # 5.0

# --- Chromosome colors (alternating palette) ---------------------------------
CHR_COLORS <- rep(c("#1B9E77", "#7570B3"), length.out = 23)

# --- Summary stats for the sidebar -------------------------------------------
n_total <- nrow(gwas)
n_significant <- sum(gwas$neglog10p >= GENOME_WIDE_SIG)
n_suggestive  <- sum(gwas$neglog10p >= SUGGESTIVE_SIG & gwas$neglog10p < GENOME_WIDE_SIG)
top_hit <- gwas[which.max(neglog10p)]
