# =============================================================================
# 01_setup.R
# -----------------------------------------------------------------------------
# Centraliza: carregamento de pacotes, seed, criação de diretórios de saída
# e funções utilitárias. Execute (ou faça source()) antes dos demais scripts.
# =============================================================================

# ---------------------------------------------------------------------------
# Pacotes
# ---------------------------------------------------------------------------

library(tidyverse)
library(ggplot2)
library(car)      # vif, Anova
library(lmtest)   # bptest (Breusch-Pagan)
library(nortest)  # ad.test

# ---------------------------------------------------------------------------
# Reprodutibilidade
# ---------------------------------------------------------------------------

set.seed(42)

# ---------------------------------------------------------------------------
# Caminhos base
# ---------------------------------------------------------------------------

BASE_DIR  <- getwd()   # raiz do projeto (definida pelo .Rproj no RStudio)
DATA_DIR  <- file.path(BASE_DIR, "data")
TAB_DIR   <- file.path(BASE_DIR, "output", "tabelas")
GRAF_DIR  <- file.path(BASE_DIR, "output", "graficos")

# Cria diretórios de saída caso não existam
dir.create(TAB_DIR,  recursive = TRUE, showWarnings = FALSE)
dir.create(GRAF_DIR, recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------------
# Funções utilitárias
# ---------------------------------------------------------------------------

#' Salva um data.frame como CSV em output/tabelas/ com mensagem de confirmação.
#'
#' @param df       data.frame a salvar.
#' @param filename Nome do arquivo (ex.: "tabela_correlacoes.csv").
salvar_tabela <- function(df, filename) {
  caminho <- file.path(TAB_DIR, filename)
  write.csv(df, file = caminho, row.names = FALSE)
  cat("Tabela salva em:", caminho, "\n")
  invisible(caminho)
}

#' Salva um ggplot como PNG em output/graficos/ com mensagem de confirmação.
#'
#' @param plot     Objeto ggplot.
#' @param filename Nome do arquivo (ex.: "dispersao_petr4_ibov.png").
#' @param width    Largura em polegadas (padrão 8).
#' @param height   Altura em polegadas (padrão 6).
#' @param dpi      Resolução (padrão 150).
salvar_grafico <- function(plot, filename, width = 8, height = 6, dpi = 150) {
  caminho <- file.path(GRAF_DIR, filename)
  ggsave(caminho, plot = plot, width = width, height = height, dpi = dpi)
  cat("Gráfico salvo:", caminho, "\n")
  invisible(caminho)
}

#' Salva um gráfico base-R (gerado com png/dev.off) em output/graficos/.
#' Retorna o caminho completo para ser usado no bloco png().
#'
#' @param filename Nome do arquivo (ex.: "qqplot_residuos.png").
caminho_grafico_base <- function(filename) {
  file.path(GRAF_DIR, filename)
}

cat("Setup carregado. BASE_DIR:", BASE_DIR, "\n")
