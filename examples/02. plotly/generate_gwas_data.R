# --- Generate simulated GWAS data -------------------------------------------
# 10 million SNPs across 23 chromosomes, with declining counts per chromosome.
# Each SNP has a position (bp) and a p-value.

library(data.table)

set.seed(42)

n_total <- 10e6
n_chr <- 23

# --- Chromosome sizes (declining from chr1 to chr23) -------------------------
# Use a simple linear decline: chr1 gets the most, chr23 the least
weights <- rev(seq_len(n_chr))
chr_sizes <- round(n_total * weights / sum(weights))

# Adjust rounding so total is exactly 10M
chr_sizes[1] <- chr_sizes[1] + (n_total - sum(chr_sizes))

message("Total SNPs: ", sum(chr_sizes))
message("Chr1: ", chr_sizes[1], " | Chr23: ", chr_sizes[23])

# --- Build the data ----------------------------------------------------------
# Pre-allocate chromosome and position vectors
chr_vec <- rep(seq_len(n_chr), times = chr_sizes)

# Position: uniform random within each chromosome's nucleotide range
# Chromosome lengths roughly proportional to their SNP count (simplified)
max_bp <- chr_sizes  # each chr spans ~as many bp as it has SNPs sampled
pos_vec <- unlist(lapply(seq_len(n_chr), function(i) {
  sort(sample.int(chr_sizes[i] * 10L, size = chr_sizes[i], replace = FALSE))
}))

# --- P-values ----------------------------------------------------------------
# Most SNPs have large p-values (not significant).
# Use a mixture: 99.5% uniform on [0,1], 0.5% from a heavy-tailed distribution
# that produces small p-values (simulating true signals).

n <- length(chr_vec)
is_signal <- runif(n) < 0.005
p_null <- runif(sum(!is_signal))
p_signal <- 10^(-runif(sum(is_signal), min = 2, max = 15))

pval_vec <- numeric(n)
pval_vec[!is_signal] <- p_null
pval_vec[is_signal] <- p_signal

# --- Assemble and write ------------------------------------------------------
gwas <- data.table(
  chr = chr_vec,
  pos = pos_vec,
  pvalue = pval_vec
)

output_path <- "examples/08_plotly/gwas_data.csv"
fwrite(gwas, output_path)
message("Wrote ", nrow(gwas), " rows to ", output_path)
message("File size: ", round(file.size(output_path) / 1e6, 1), " MB")
