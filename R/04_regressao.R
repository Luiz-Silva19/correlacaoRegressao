# =============================================================================
# 04_regressao.R
# -----------------------------------------------------------------------------
# Regressão linear múltipla: retorno PETR4 ~ IBOV + Brent + Dólar.
# Implementa MQO manual, inferência, ANOVA e diagnóstico completo de resíduos.
# =============================================================================

source("R/01_setup.R")

# ---------------------------------------------------------------------------
# Caminhos
# ---------------------------------------------------------------------------

INPUT_CSV <- file.path(DATA_DIR, "dados_tratados.csv")

cat("=== Regressão Linear Múltipla ===\n\n")

# ---------------------------------------------------------------------------
# Leitura dos dados
# ---------------------------------------------------------------------------

df <- read.csv(INPUT_CSV, stringsAsFactors = FALSE)
df$data <- as.Date(df$data)
n <- nrow(df)
cat("Observações:", n, "\n\n")

Y  <- df$retorno_petr4   # variável dependente
X1 <- df$retorno_ibov
X2 <- df$retorno_brent
X3 <- df$retorno_dolar

# ---------------------------------------------------------------------------
# 1. Estimação via MQO — implementação manual com álgebra matricial
# ---------------------------------------------------------------------------

cat("--- 1. MQO — Álgebra Matricial ---\n")

# Matriz de design (com intercepto)
X_mat <- cbind(1, X1, X2, X3)
colnames(X_mat) <- c("intercepto", "retorno_ibov", "retorno_brent", "retorno_dolar")

# Beta = (X'X)^{-1} X'Y
XtX     <- t(X_mat) %*% X_mat
XtY     <- t(X_mat) %*% Y
beta_hat <- solve(XtX) %*% XtY

cat("Coeficientes estimados (MQO manual):\n")
print(round(beta_hat, 6))

# Valores ajustados e resíduos
Y_hat  <- X_mat %*% beta_hat
e      <- Y - Y_hat

# ---------------------------------------------------------------------------
# 2. Modelo via lm() para validação
# ---------------------------------------------------------------------------

cat("\n--- 2. Validação com lm() ---\n")
modelo <- lm(retorno_petr4 ~ retorno_ibov + retorno_brent + retorno_dolar, data = df)
coef_lm <- coef(modelo)
cat("Coeficientes via lm():\n")
print(round(coef_lm, 6))

equiv <- all(abs(beta_hat - coef_lm) < 1e-6)
cat(sprintf("Coeficientes equivalentes: %s\n", ifelse(equiv, "SIM", "VERIFICAR")))

# ---------------------------------------------------------------------------
# 3. Erros padrão e testes t dos coeficientes
# ---------------------------------------------------------------------------

cat("\n--- 3. Erros Padrão e Teste t dos Coeficientes ---\n")
cat("H0: βi = 0  |  H1: βi ≠ 0\n\n")

k    <- ncol(X_mat)          # número de parâmetros (inclui intercepto)
gl_e <- n - k                # graus de liberdade do erro
SQRes <- sum(e^2)
s2   <- SQRes / gl_e         # variância do erro

cov_beta <- s2 * solve(XtX)
ep_beta  <- sqrt(diag(cov_beta))

t_stat  <- beta_hat / ep_beta
p_valor <- 2 * pt(-abs(t_stat), df = gl_e)

tabela_coef <- data.frame(
  coeficiente  = rownames(beta_hat),
  estimativa   = round(beta_hat[, 1], 4),
  erro_padrao  = round(ep_beta,       4),
  t_stat       = round(t_stat[, 1],  4),
  p_value      = round(p_valor[, 1], 6),
  significativo = ifelse(p_valor[, 1] < 0.05, "Sim (*)", "Não")
)

print(tabela_coef)
salvar_tabela(tabela_coef, "coeficientes_regressao.csv")

cat("\nInterpretação econômica:\n")
b <- round(beta_hat[, 1], 4)
cat(sprintf("  β0 (intercepto): %.4f — retorno esperado de PETR4 quando todas as variáveis são zero.\n", b["intercepto"]))
cat(sprintf("  β1 (IBOV):       %.4f — para cada 1%% de variação do IBOV, PETR4 varia %.4f%%.\n",  b["retorno_ibov"],  b["retorno_ibov"]))
cat(sprintf("  β2 (Brent):      %.4f — para cada 1%% de variação do Brent, PETR4 varia %.4f%%.\n", b["retorno_brent"], b["retorno_brent"]))
cat(sprintf("  β3 (Dólar):      %.4f — para cada 1%% de variação do Dólar, PETR4 varia %.4f%%.\n", b["retorno_dolar"], b["retorno_dolar"]))

# ---------------------------------------------------------------------------
# 4. R² e R² Ajustado
# ---------------------------------------------------------------------------

cat("\n--- 4. R² e R² Ajustado ---\n")

Y_barra <- mean(Y)
SQTotal <- sum((Y - Y_barra)^2)
SQReg   <- sum((Y_hat - Y_barra)^2)
# SQRes já calculado acima

R2      <- SQReg / SQTotal
R2_adj  <- 1 - (SQRes / gl_e) / (SQTotal / (n - 1))

cat(sprintf("  R²          manual = %.6f\n", R2))
cat(sprintf("  R² Ajustado manual = %.6f\n", R2_adj))
cat(sprintf("  R²          lm()   = %.6f\n", summary(modelo)$r.squared))
cat(sprintf("  R² Ajustado lm()   = %.6f\n", summary(modelo)$adj.r.squared))
cat(sprintf("  R²: %.2f%% da variação dos retornos de PETR4 é explicada pelo modelo.\n", R2 * 100))

# ---------------------------------------------------------------------------
# 5. ANOVA da Regressão
# ---------------------------------------------------------------------------

cat("\n--- 5. ANOVA da Regressão ---\n")
cat("H0: β1 = β2 = β3 = 0  |  H1: pelo menos um βi ≠ 0\n\n")

gl_reg <- k - 1   # gl da regressão (sem intercepto)

QMReg  <- SQReg  / gl_reg
QMRes  <- SQRes  / gl_e

F_calc  <- QMReg / QMRes
F_crit  <- qf(0.95, df1 = gl_reg, df2 = gl_e)
p_F     <- pf(F_calc, df1 = gl_reg, df2 = gl_e, lower.tail = FALSE)

tabela_anova <- data.frame(
  fonte       = c("Regressão", "Resíduo", "Total"),
  SQ          = round(c(SQReg, SQRes, SQTotal), 4),
  gl          = c(gl_reg, gl_e, n - 1),
  QM          = round(c(QMReg, QMRes, NA), 4),
  F_stat      = round(c(F_calc, NA, NA), 4),
  p_value     = round(c(p_F, NA, NA), 6)
)

print(tabela_anova)

cat(sprintf("\nValidação: SQTotal = SQReg + SQRes → %.4f = %.4f + %.4f → %s\n",
            SQTotal, SQReg, SQRes,
            ifelse(abs(SQTotal - (SQReg + SQRes)) < 1e-6, "CORRETO", "VERIFICAR")))

cat(sprintf("F calculado = %.4f  |  F crítico (5%%) = %.4f\n", F_calc, F_crit))
cat(sprintf("p-value     = %.6f\n", p_F))
cat(sprintf("Decisão H0  : %s\n",
            ifelse(F_calc > F_crit,
                   "REJEITA H0 — modelo globalmente significativo",
                   "NÃO rejeita H0")))

write.csv(tabela_anova, file.path(TAB_DIR, "anova_regressao.csv"), row.names = FALSE)
cat("ANOVA salva em:", file.path(TAB_DIR, "anova_regressao.csv"), "\n")

# ---------------------------------------------------------------------------
# 6. Diagnóstico dos Resíduos
# ---------------------------------------------------------------------------

cat("\n--- 6. Diagnóstico dos Resíduos ---\n")

residuos   <- as.numeric(e)
ajustados  <- as.numeric(Y_hat)
df_diag    <- data.frame(residuos = residuos, ajustados = ajustados)

# 6.1 Histograma dos resíduos
g_hist <- ggplot(df_diag, aes(x = residuos)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 15, fill = "steelblue", color = "white", alpha = 0.8) +
  geom_density(color = "red", linewidth = 1) +
  labs(title = "Histograma dos Resíduos",
       x = "Resíduos", y = "Densidade") +
  theme_minimal(base_size = 13)

salvar_grafico(g_hist, "hist_residuos.png")

# 6.2 QQ Plot dos resíduos
arq_qq <- caminho_grafico_base("qqplot_residuos.png")
png(arq_qq, width = 800, height = 600)
qqnorm(residuos, main = "QQ Plot dos Resíduos", col = "steelblue", pch = 16)
qqline(residuos, col = "red", lwd = 2)
dev.off()
cat("QQ Plot dos resíduos salvo:", arq_qq, "\n")

# 6.3 Resíduos versus Ajustados (homocedasticidade)
g_rv <- ggplot(df_diag, aes(x = ajustados, y = residuos)) +
  geom_point(color = "steelblue", alpha = 0.7, size = 2.5) +
  geom_hline(yintercept = 0, color = "red", linewidth = 1, linetype = "dashed") +
  geom_smooth(method = "loess", se = FALSE, color = "orange", linewidth = 1) +
  labs(title    = "Resíduos vs Valores Ajustados",
       subtitle  = "Avaliação de homocedasticidade",
       x = "Valores Ajustados (%)", y = "Resíduos (%)") +
  theme_minimal(base_size = 13)

salvar_grafico(g_rv, "residuos_vs_ajustados.png")

# 6.4 Testes formais dos resíduos
cat("\nTeste de Shapiro-Wilk nos resíduos:\n")
sw_res <- shapiro.test(residuos)
cat(sprintf("  W = %.4f  |  p-value = %.4f  |  Normalidade: %s\n",
            sw_res$statistic, sw_res$p.value,
            ifelse(sw_res$p.value > 0.05, "Não rejeitada", "Rejeitada (p < 0,05)")))

cat("\nTeste de Breusch-Pagan (homocedasticidade):\n")
bp <- bptest(modelo)
cat(sprintf("  BP = %.4f  |  p-value = %.4f  |  Homocedasticidade: %s\n",
            bp$statistic, bp$p.value,
            ifelse(bp$p.value > 0.05, "Não rejeitada", "Rejeitada (p < 0,05)")))

# VIF — multicolinearidade
cat("\nFator de Inflação da Variância (VIF):\n")
vif_vals <- vif(modelo)
print(round(vif_vals, 2))

tabela_diag <- data.frame(
  teste            = c("Shapiro-Wilk (normalidade)", "Breusch-Pagan (homocedasticidade)"),
  estatistica      = round(c(sw_res$statistic, bp$statistic), 4),
  p_value          = round(c(sw_res$p.value,   bp$p.value),   4),
  pressuposto_ok   = c(sw_res$p.value > 0.05,  bp$p.value > 0.05)
)

salvar_tabela(tabela_diag, "diagnostico_residuos.csv")

# ---------------------------------------------------------------------------
# 6.5 Interpretação textual dos diagnósticos
# ---------------------------------------------------------------------------

norm_ok  <- sw_res$p.value > 0.05
homo_ok  <- bp$p.value > 0.05
vif_max  <- max(vif_vals)
multi_ok <- vif_max < 10

linhas_diag <- c(
  "# Interpretação dos Diagnósticos do Modelo de Regressão",
  "",
  paste("Gerado em:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  "## Normalidade dos Resíduos (Shapiro-Wilk)",
  sprintf("  W = %.4f  |  p-value = %.4f", sw_res$statistic, sw_res$p.value),
  ifelse(norm_ok,
    "  Conclusão: Não há evidência suficiente para rejeitar a normalidade dos resíduos (p > 0,05).",
    "  Conclusão: A hipótese de normalidade dos resíduos é rejeitada (p < 0,05). Interpretar inferências com cautela."),
  "",
  "## Homocedasticidade (Breusch-Pagan)",
  sprintf("  BP = %.4f  |  p-value = %.4f", bp$statistic, bp$p.value),
  ifelse(homo_ok,
    "  Conclusão: Não há evidência de heterocedasticidade (p > 0,05). Variância dos resíduos é homogênea.",
    "  Conclusão: Heterocedasticidade detectada (p < 0,05). Considerar erros padrão robustos ou transformação da variável resposta."),
  "",
  "## Multicolinearidade (VIF)",
  sprintf("  VIF máximo = %.2f", vif_max),
  ifelse(multi_ok,
    "  Conclusão: Sem multicolinearidade severa (VIF < 10). Coeficientes são interpretáveis individualmente.",
    "  Conclusão: Multicolinearidade elevada detectada (VIF >= 10). Avaliar remoção ou combinação de preditores.")
)

caminho_diag_txt <- file.path(TAB_DIR, "diagnostico_interpretacao.md")
writeLines(linhas_diag, caminho_diag_txt)
cat("Interpretação dos diagnósticos salva em:", caminho_diag_txt, "\n")

# ---------------------------------------------------------------------------
# 7. Resumo geral do modelo
# ---------------------------------------------------------------------------

cat("\n=== Resumo do Modelo ===\n")
print(summary(modelo))

cat("\n=== Regressão Linear concluída ===\n")
