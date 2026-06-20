# =============================================================================
# 02_sanitizacao.R
# -----------------------------------------------------------------------------
# Lê o CSV gerado pelo Python, verifica e corrige problemas de qualidade de
# dados, gera estatísticas descritivas e salva o dataset tratado.
# =============================================================================

source("R/01_setup.R")

# ---------------------------------------------------------------------------
# Caminhos
# ---------------------------------------------------------------------------

INPUT_CSV  <- file.path(DATA_DIR, "dados_mercado.csv")
OUTPUT_CSV <- file.path(DATA_DIR, "dados_tratados.csv")

cat("=== Sanitização dos Dados ===\n\n")

# ---------------------------------------------------------------------------
# 1. Leitura
# ---------------------------------------------------------------------------

cat("1. Lendo arquivo:", INPUT_CSV, "\n")
df <- read.csv(INPUT_CSV, stringsAsFactors = FALSE)
df$data <- as.Date(df$data)

cat("   Dimensões iniciais:", nrow(df), "linhas x", ncol(df), "colunas\n\n")
print(head(df))

# ---------------------------------------------------------------------------
# 2. Verificação de valores ausentes
# ---------------------------------------------------------------------------

cat("\n--- 2. Valores Ausentes ---\n")
na_por_coluna <- colSums(is.na(df))
print(na_por_coluna)

linhas_com_na <- df[rowSums(is.na(df)) > 0, ]
if (nrow(linhas_com_na) > 0) {
  cat("Linhas com NA:\n")
  print(linhas_com_na)
} else {
  cat("Nenhuma linha com valores ausentes.\n")
}

# ---------------------------------------------------------------------------
# 3. Verificação de duplicidades
# ---------------------------------------------------------------------------

cat("\n--- 3. Duplicidades ---\n")
dups <- df[duplicated(df$data), ]
if (nrow(dups) > 0) {
  cat("Datas duplicadas encontradas:\n")
  print(dups)
} else {
  cat("Nenhuma data duplicada.\n")
}

# ---------------------------------------------------------------------------
# 4. Verificação de inconsistências (retornos fora de range plausível)
# ---------------------------------------------------------------------------

cat("\n--- 4. Inconsistências (retornos > 100% ou < -80%) ---\n")
vars_retorno <- c("retorno_petr4", "retorno_ibov", "retorno_brent", "retorno_dolar")

inconsistentes <- df %>%
  filter(if_any(all_of(vars_retorno), ~ . > 100 | . < -80))

if (nrow(inconsistentes) > 0) {
  cat("Linhas com retornos suspeitos:\n")
  print(inconsistentes)
} else {
  cat("Nenhum retorno fora do intervalo plausível.\n")
}

# ---------------------------------------------------------------------------
# 5. Remoção de registros inválidos (NAs)
# ---------------------------------------------------------------------------

cat("\n--- 5. Remoção de Registros Inválidos ---\n")
df_tratado <- df %>%
  filter(!is.na(retorno_petr4) & !is.na(retorno_ibov) &
         !is.na(retorno_brent) & !is.na(retorno_dolar)) %>%
  distinct(data, .keep_all = TRUE) %>%
  arrange(data)

cat("Linhas removidas:", nrow(df) - nrow(df_tratado), "\n")
cat("Dimensões finais:", nrow(df_tratado), "linhas x", ncol(df_tratado), "colunas\n")

# ---------------------------------------------------------------------------
# 6. Estatísticas Descritivas
# ---------------------------------------------------------------------------

cat("\n--- 6. Estatísticas Descritivas ---\n")

coef_var <- function(x) (sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)) * 100

descritivas <- df_tratado %>%
  select(all_of(vars_retorno)) %>%
  pivot_longer(everything(), names_to = "variavel", values_to = "valor") %>%
  group_by(variavel) %>%
  summarise(
    n        = n(),
    media    = mean(valor, na.rm = TRUE),
    mediana  = median(valor, na.rm = TRUE),
    desvpad  = sd(valor, na.rm = TRUE),
    minimo   = min(valor, na.rm = TRUE),
    maximo   = max(valor, na.rm = TRUE),
    cv_pct   = coef_var(valor),
    .groups  = "drop"
  ) %>%
  mutate(across(where(is.numeric), ~ round(., 4)))

print(descritivas)

# Salva tabela de estatísticas descritivas
salvar_tabela(descritivas, "estatisticas_descritivas.csv")

# ---------------------------------------------------------------------------
# 7. Salvar dataset tratado
# ---------------------------------------------------------------------------

write.csv(df_tratado, file = OUTPUT_CSV, row.names = FALSE)
cat("Dataset tratado salvo em:", OUTPUT_CSV, "\n")

cat("\n=== Sanitização concluída ===\n")
