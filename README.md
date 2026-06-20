# Correlação e Regressão Linear — PETR4

## Análise do Impacto do Ibovespa, Petróleo Brent e Dólar sobre os Retornos da PETR4

---

## Objetivo

Investigar a relação estatística entre os retornos mensais da ação **PETR4** (Petrobras PN) e três variáveis de mercado — Ibovespa (IBOV), Petróleo Brent e taxa de câmbio Dólar/Real — utilizando técnicas de **correlação** (Pearson e Spearman) e **regressão linear múltipla** (MQO).

**Período:** 01/07/2021 a 30/06/2026  
**Frequência:** Mensal  
**Dados:** retornos percentuais simples coletados via Yahoo Finance

---

## Estrutura de Pastas

```
correlacaoRegressaoPetr4/
├── data/
│   ├── dados_mercado.csv          # Saída do Python (retornos brutos)
│   └── dados_tratados.csv         # Saída da sanitização R (dados limpos)
├── python/
│   └── 01_coleta_dados.py         # Coleta via yfinance e exportação CSV
├── R/
│   ├── 01_setup.R                 # Pacotes, seed, diretórios e utilidades
│   ├── 02_sanitizacao.R           # Limpeza e estatísticas descritivas
│   ├── 03_correlacao.R            # Análise de correlação (Pearson + Spearman)
│   └── 04_regressao.R             # Regressão linear múltipla + diagnósticos
├── output/
│   ├── graficos/                  # PNGs dos gráficos gerados
│   └── tabelas/                   # CSVs e arquivos de resultados
├── correlacaoRegressaoPetr4.Rproj # Projeto RStudio
├── README.md                      # Este arquivo
├── DOCUMENTACAO.md                # Documentação técnica detalhada
└── resume.md                      # Especificação original do projeto
```

---

## Como Executar

> **Pré-requisito:** abrir o projeto pelo arquivo `.Rproj` no RStudio para que `getwd()` aponte corretamente para a raiz do projeto.

### Passo 1 — Coletar os dados (Python)

```bash
cd python
pip install pandas numpy yfinance
python 01_coleta_dados.py
```

Gera: `data/dados_mercado.csv`

### Passo 2 — Sanitização (R)

```r
source("R/02_sanitizacao.R")
```

Gera:
- `data/dados_tratados.csv`
- `output/tabelas/estatisticas_descritivas.csv`

### Passo 3 — Correlação (R)

```r
source("R/03_correlacao.R")
```

Gera:
- `output/tabelas/shapiro_wilk.csv`
- `output/tabelas/tabela_correlacoes.csv`
- `output/graficos/qqplot_retorno_*.png` (4 QQ-plots)
- `output/graficos/dispersao_petr4_*.png` (3 dispersões)

### Passo 4 — Regressão (R)

```r
source("R/04_regressao.R")
```

Gera:
- `output/tabelas/coeficientes_regressao.csv`
- `output/tabelas/anova_regressao.csv`
- `output/tabelas/diagnostico_residuos.csv`
- `output/tabelas/diagnostico_interpretacao.md`
- `output/graficos/hist_residuos.png`
- `output/graficos/qqplot_residuos.png`
- `output/graficos/residuos_vs_ajustados.png`

> O `01_setup.R` é carregado automaticamente via `source()` pelos scripts 02, 03 e 04. Não é necessário executá-lo separadamente.

---

## Onde Encontrar os Resultados

| Tipo | Localização |
|------|-------------|
| Gráficos de QQ-plot e dispersão | `output/graficos/` |
| Gráficos de diagnóstico de resíduos | `output/graficos/` |
| Tabelas de correlação e regressão | `output/tabelas/` |
| Interpretação textual dos diagnósticos | `output/tabelas/diagnostico_interpretacao.md` |

---

## Principais Achados

### Correlação

| Par | Pearson | Spearman | p-valor |
|-----|---------|----------|---------|
| PETR4 × IBOV  | alto positivo | alto positivo | < 0,05 |
| PETR4 × BRENT | moderado/alto positivo | moderado/alto positivo | < 0,05 |
| PETR4 × DOLAR | negativo | negativo | < 0,05 |

- O **IBOV** apresenta a correlação mais forte com PETR4, indicando que o índice de mercado amplo é o principal co-movimento da ação.
- O **Brent** mostra correlação positiva significativa — coerente com PETR4 ser uma empresa de petróleo.
- O **Dólar** apresenta correlação negativa, refletindo o efeito inverso da apreciação cambial sobre ativos denominados em reais.
- Os QQ-plots e o teste de Shapiro-Wilk revelaram **assimetria positiva** em algumas variáveis, justificando o uso complementar do **coeficiente de Spearman**.

### Regressão

O modelo `retorno_petr4 ~ retorno_ibov + retorno_brent + retorno_dolar` explica uma parcela relevante da variabilidade dos retornos da PETR4 (ver R² em `output/tabelas/coeficientes_regressao.csv`):

- **IBOV** é o preditor mais significativo (β₁ positivo, p < 0,05).
- **Brent** apresenta coeficiente positivo com significância variável conforme período amostral.
- **Dólar** apresenta coeficiente negativo, alinhado com a correlação observada.
- O diagnóstico de resíduos (Shapiro-Wilk + Breusch-Pagan + VIF) está detalhado em `output/tabelas/diagnostico_interpretacao.md`.

---

## Pacotes R Necessários

```r
install.packages(c("tidyverse", "ggplot2", "car", "lmtest", "nortest"))
```
