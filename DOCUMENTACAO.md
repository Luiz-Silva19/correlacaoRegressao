# Documentação Técnica — Correlação e Regressão Linear: PETR4

## Análise do Impacto do Ibovespa, Petróleo Brent e Dólar sobre os Retornos da PETR4

---

## Sumário

1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Estrutura de Arquivos](#2-estrutura-de-arquivos)
3. [Como Executar o Projeto](#3-como-executar-o-projeto)
4. [Etapa 1 — Coleta de Dados (Python)](#4-etapa-1--coleta-de-dados-python)
5. [Etapa 2 — Sanitização (R)](#5-etapa-2--sanitização-r)
6. [Etapa 3 — Correlação (R)](#6-etapa-3--correlação-r)
7. [Etapa 4 — Regressão Linear (R)](#7-etapa-4--regressão-linear-r)
8. [Pacotes Utilizados](#8-pacotes-utilizados)
9. [Outputs Gerados](#9-outputs-gerados)

---

## 1. Visão Geral do Projeto

O projeto investiga a relação estatística entre os retornos mensais da ação **PETR4** (Petrobras PN) e três variáveis explicativas de mercado:

| Variável | Ticker Yahoo Finance | Descrição                        |
| -------- | -------------------- | -------------------------------- |
| PETR4    | `PETR4.SA`           | Ação preferencial da Petrobras   |
| IBOV     | `^BVSP`              | Índice Bovespa                   |
| Brent    | `BZ=F`               | Petróleo Brent (contrato futuro) |
| Dólar    | `BRL=X`              | Taxa de câmbio USD/BRL           |

**Período:** 01/07/2021 a 30/06/2026  
**Frequência:** Mensal  
**Métrica:** Retorno percentual simples

---

## 2. Estrutura de Arquivos

```
correlacaoRegressaoPetr4/
├── data/
│   ├── dados_mercado.csv       # Saída do Python (retornos brutos)
│   └── dados_tratados.csv      # Saída do R sanitização (dados limpos)
├── python/
│   └── 01_coleta_dados.py      # Coleta e exportação via yfinance
├── R/
│   ├── 02_sanitizacao.R        # Limpeza e estatísticas descritivas
│   ├── 03_correlacao.R         # Análise de correlação
│   └── 04_regressao.R          # Regressão linear múltipla
├── output/
│   ├── tabelas/                # CSVs com resultados
│   ├── graficos/               # PNGs dos gráficos
│   └── relatorios/
├── correlacaoRegressaoPetr4.Rproj  # Projeto RStudio
├── resume.md                   # Especificação do projeto
└── DOCUMENTACAO.md             # Este arquivo
```

---

## 3. Como Executar o Projeto

### 3.1 Pré-requisitos

**Python (≥ 3.9):**

```
pip install yfinance pandas numpy
```

**R (≥ 4.2) — instalar pacotes uma única vez no console do RStudio:**

```r
install.packages(c("tidyverse", "ggplot2", "psych", "car", "lmtest", "nortest"))
```

---

### 3.2 Passo a Passo Completo

#### Passo 1 — Abrir o projeto no RStudio

Abra o arquivo `correlacaoRegressaoPetr4.Rproj` com duplo clique ou via:
_File → Open Project → selecionar `correlacaoRegressaoPetr4.Rproj`_

> O RStudio definirá automaticamente o diretório de trabalho como a raiz do projeto. Todos os scripts R dependem disso para localizar os arquivos de dados e salvar os outputs.

#### Passo 2 — Coletar os dados (Python)

Em um terminal (PowerShell, Bash ou terminal integrado do VS Code), dentro da pasta raiz do projeto:

```bash
python python/01_coleta_dados.py
```

**Saída esperada no terminal:**

```
=== Coleta de Dados de Mercado ===

Baixando dados de PETR4.SA (petr4)...
	Observações brutas: 61 | Retornos calculados: 60
Baixando dados de ^BVSP (ibov)...
	Observações brutas: 61 | Retornos calculados: 60
Baixando dados de BZ=F (brent)...
	Observações brutas: 61 | Retornos calculados: 60
Baixando dados de BRL=X (dolar)...
	Observações brutas: 61 | Retornos calculados: 60

Consolidando séries...
Linhas após remoção de NaN iniciais: 60

Arquivo exportado: .../data/dados_mercado.csv
=== Coleta concluída com sucesso ===
```

Arquivo gerado: `data/dados_mercado.csv`

#### Passo 3 — Sanitização (R)

No RStudio, com o projeto aberto, abra `R/02_sanitizacao.R` e execute com **Ctrl+Shift+Enter** (rodar o script inteiro) ou via console:

```r
source("R/02_sanitizacao.R")
```

**Saída esperada:**

```
=== Sanitização dos Dados ===

1. Lendo arquivo: .../data/dados_mercado.csv
	 Dimensões iniciais: 60 linhas x 5 colunas

--- 2. Valores Ausentes ---
data  retorno_petr4  retorno_ibov  retorno_brent  retorno_dolar
	 0              0             0              0              0
Nenhuma linha com valores ausentes.

--- 3. Duplicidades ---
Nenhuma data duplicada.

--- 4. Inconsistências (retornos > 100% ou < -80%) ---
Nenhum retorno fora do intervalo plausível.

--- 5. Remoção de Registros Inválidos ---
Linhas removidas: 0
Dimensões finais: 60 linhas x 5 colunas

--- 6. Estatísticas Descritivas ---
# (tabela impressa no console)

Tabela salva em: .../output/tabelas/estatisticas_descritivas.csv
Dataset tratado salvo em: .../data/dados_tratados.csv
=== Sanitização concluída ===
```

Arquivos gerados:

- `data/dados_tratados.csv`
- `output/tabelas/estatisticas_descritivas.csv`

#### Passo 4 — Análise de Correlação (R)

```r
source("R/03_correlacao.R")
```

**Trecho esperado no console (Pearson — 3 formas):**

```
--- Pearson: PETR4 × IBOV ---
	Forma 1 (Z-score):            r = 0.xxxxxx
	Forma 2 (Desvios da média):   r = 0.xxxxxx
	Forma 3 (Somas brutas):       r = 0.xxxxxx
	cor() nativo:                 r = 0.xxxxxx
	Todas as formas equivalentes: SIM
```

Arquivos gerados:

- `output/tabelas/shapiro_wilk.csv`
- `output/tabelas/tabela_correlacoes.csv`
- `output/graficos/qqplot_retorno_*.png` (4 arquivos)
- `output/graficos/dispersao_petr4_*.png` (3 arquivos)

#### Passo 5 — Regressão Linear Múltipla (R)

```r
source("R/04_regressao.R")
```

**Trecho esperado no console (ANOVA):**

```
--- 5. ANOVA da Regressão ---
H0: β1 = β2 = β3 = 0  |  H1: pelo menos um βi ≠ 0

			 fonte      SQ gl    QM F_stat p_value
1  Regressão  xx.xx  3 xx.xx  xx.xx  0.xxxx
2    Resíduo  xx.xx 56 xx.xx     NA      NA
3      Total  xx.xx 59    NA     NA      NA

Validação: SQTotal = SQReg + SQRes → CORRETO
Decisão H0 : REJEITA H0 — modelo globalmente significativo
```

Arquivos gerados:

- `output/tabelas/coeficientes_regressao.csv`
- `output/tabelas/anova_regressao.csv`
- `output/tabelas/diagnostico_residuos.csv`
- `output/graficos/hist_residuos.png`
- `output/graficos/qqplot_residuos.png`
- `output/graficos/residuos_vs_ajustados.png`

---

### 3.3 Executar Tudo de Uma Vez (R)

Com o projeto aberto no RStudio, execute no console:

```r
source("R/02_sanitizacao.R")
source("R/03_correlacao.R")
source("R/04_regressao.R")
```

> **Importante:** a coleta Python (Passo 2) deve ser executada antes. Os scripts R dependem de `data/dados_mercado.csv`.

---

## 4. Etapa 1 — Coleta de Dados (Python)

**Arquivo:** `python/01_coleta_dados.py`
**Pacotes:** `yfinance`, `pandas`, `numpy`

### 3.1 Download dos Dados

Utiliza a biblioteca `yfinance` para baixar séries históricas mensais com preço ajustado (`auto_adjust=True`), que já incorpora splits, bonificações e dividendos ao preço de fechamento.

```python
yf.download(ticker, start=inicio, end=fim, interval="1mo", auto_adjust=True)
```

### 3.2 Cálculo do Retorno Percentual Simples

O retorno mensal de cada ativo é calculado pela fórmula do **retorno aritmético simples**:

$$R_t = \frac{P_t - P_{t-1}}{P_{t-1}} \times 100$$

Onde:

- $R_t$ = retorno no mês $t$ (em %)
- $P_t$ = preço ajustado de fechamento no mês $t$
- $P_{t-1}$ = preço ajustado de fechamento no mês anterior

> **Nota:** Optou-se pelo retorno aritmético simples (e não log-retorno) por ser de interpretação mais direta em análises de regressão.

### 3.3 Normalização do Índice Temporal

O índice de datas é convertido para o primeiro dia de cada mês (`to_period("M").to_timestamp()`) para garantir alinhamento entre os quatro ativos.

### 3.4 Saída

CSV com colunas: `data`, `retorno_petr4`, `retorno_ibov`, `retorno_brent`, `retorno_dolar`.

---

## 4. Etapa 2 — Sanitização (R)

**Arquivo:** `R/02_sanitizacao.R`
**Pacotes:** `tidyverse`

### 4.1 Verificação de Valores Ausentes

Inspeção coluna a coluna com `colSums(is.na(df))`. Linhas com `NA` em qualquer variável de retorno são removidas via `filter(!is.na(...))`.

### 4.2 Verificação de Duplicidades

Datas duplicadas são identificadas com `duplicated(df$data)` e removidas com `distinct(data, .keep_all = TRUE)`.

### 4.3 Verificação de Inconsistências

Retornos fora do intervalo plausível (`> 100%` ou `< -80%`) são sinalizados para inspeção manual, permitindo ao analista decidir sobre remoção ou manutenção.

### 4.4 Estatísticas Descritivas

Para cada variável de retorno são calculadas:

| Estatística             | Fórmula                                        | Função R                 |
| ----------------------- | ---------------------------------------------- | ------------------------ |
| Média                   | $\bar{x} = \frac{1}{n}\sum_{i=1}^n x_i$        | `mean()`                 |
| Mediana                 | valor central da distribuição ordenada         | `median()`               |
| Desvio Padrão           | $s = \sqrt{\frac{\sum(x_i - \bar{x})^2}{n-1}}$ | `sd()`                   |
| Mínimo                  | $\min(x)$                                      | `min()`                  |
| Máximo                  | $\max(x)$                                      | `max()`                  |
| Coeficiente de Variação | $CV = \frac{s}{\bar{x}} \times 100$            | implementado manualmente |

O **Coeficiente de Variação (CV)** é uma medida de dispersão relativa que permite comparar a variabilidade entre variáveis com diferentes escalas de média.

---

## 5. Etapa 3 — Correlação (R)

**Arquivo:** `R/03_correlacao.R`
**Pacotes:** `tidyverse`, `ggplot2`, `nortest`, `psych`

### 5.1 Verificação da Normalidade

#### 5.1.1 QQ Plot (Quantile-Quantile Plot)

Compara os quantis empíricos da variável com os quantis teóricos de uma distribuição normal. Pontos alinhados sobre a linha de referência indicam normalidade.

- Gerado com `qqnorm()` e `qqline()` do R base.
- Salvo em `output/graficos/qqplot_<variavel>.png`.

#### 5.1.2 Teste de Shapiro-Wilk

Testa a hipótese de normalidade da distribuição:

$$H_0: \text{os dados seguem distribuição normal}$$
$$H_1: \text{os dados não seguem distribuição normal}$$

A estatística $W$ é calculada como:

$$W = \frac{\left(\sum_{i=1}^n a_i x_{(i)}\right)^2}{\sum_{i=1}^n (x_i - \bar{x})^2}$$

Onde $x_{(i)}$ são os valores ordenados e $a_i$ são coeficientes tabelados.

- Função R: `shapiro.test()`
- Critério de decisão: rejeita $H_0$ se $p < 0{,}05$

**Decisão sobre o método de correlação:**

- Se todas as variáveis passam em Shapiro-Wilk → Pearson é o método principal
- Se alguma variável rejeita normalidade → Pearson e Spearman são ambos reportados

---

### 5.2 Correlação de Pearson — Três Formas

O **coeficiente de correlação de Pearson** mede a força e direção da associação linear entre duas variáveis contínuas. Varia entre $-1$ e $+1$.

#### Forma 1 — Z-scores (Escores Padronizados)

Cada variável é padronizada subtraindo a média e dividindo pelo desvio padrão:

$$z_{x_i} = \frac{x_i - \bar{x}}{s_x}, \quad z_{y_i} = \frac{y_i - \bar{y}}{s_y}$$

$$r = \frac{\sum_{i=1}^n z_{x_i} \cdot z_{y_i}}{n - 1}$$

#### Forma 2 — Desvios em Relação à Média

$$r = \frac{\sum_{i=1}^n (x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum_{i=1}^n (x_i - \bar{x})^2 \cdot \sum_{i=1}^n (y_i - \bar{y})^2}}$$

Esta é a definição canônica do coeficiente de Pearson, equivalente ao cosseno do ângulo entre os vetores de desvios centralizados.

#### Forma 3 — Somas Brutas (Fórmula Computacional)

Algebricamente equivalente às formas anteriores, mas evita o cálculo intermediário de médias, sendo útil para computação em série:

$$r = \frac{n\sum x_i y_i - \sum x_i \sum y_i}{\sqrt{\left[n\sum x_i^2 - \left(\sum x_i\right)^2\right]\left[n\sum y_i^2 - \left(\sum y_i\right)^2\right]}}$$

**Validação:** os três resultados são comparados entre si e com a função nativa `cor(x, y)` do R. A tolerância numérica aceita é $|r_{\text{manual}} - r_{\text{nativo}}| < 10^{-8}$.

---

### 5.3 Inferência para Pearson

#### 5.3.1 Teste de Hipóteses

Para cada par de variáveis:

$$H_0: \rho = 0 \quad \text{(não há correlação linear na população)}$$
$$H_1: \rho \neq 0 \quad \text{(há correlação linear na população)}$$

#### 5.3.2 Estatística de Teste

Sob $H_0$, a estatística:

$$t = \frac{r\sqrt{n-2}}{\sqrt{1-r^2}}$$

segue distribuição $t$-Student com $\nu = n - 2$ graus de liberdade.

- **Região de rejeição (bilateral):** $|t_{\text{calc}}| > t_{\text{crítico}}$, onde $t_{\text{crítico}} = t_{\alpha/2;\, n-2}$
- **p-value:** `2 * pt(-abs(t_calc), df = n-2)`
- **Decisão:** rejeita $H_0$ se $p < 0{,}05$

#### 5.3.3 Intervalo de Confiança — Transformação Z de Fisher

A distribuição amostral de $r$ é assimétrica (especialmente para $|r|$ grande). A **transformação Z de Fisher** normaliza essa distribuição:

$$Z_r = \frac{1}{2}\ln\!\left(\frac{1+r}{1-r}\right) = \tanh^{-1}(r)$$

A variável $Z_r$ é aproximadamente normal com:

$$Z_r \sim N\!\left(\frac{1}{2}\ln\!\frac{1+\rho}{1-\rho},\; \frac{1}{\sqrt{n-3}}\right)$$

O **intervalo de confiança de 95%** em escala $Z$ é:

$$\left[Z_r - z_{0{,}025} \cdot \frac{1}{\sqrt{n-3}}\;;\; Z_r + z_{0{,}025} \cdot \frac{1}{\sqrt{n-3}}\right]$$

Transformando de volta para a escala de $r$:

$$r = \frac{e^{2Z} - 1}{e^{2Z} + 1} = \tanh(Z)$$

---

### 5.4 Correlação de Spearman

O **coeficiente de correlação de Spearman** ($r_s$) é uma medida não paramétrica baseada nos **postos (ranks)** das observações. É mais robusto à presença de outliers e não exige normalidade.

#### Implementação Manual

1. Calcular os ranks de $x$ e $y$: $R_x = \text{rank}(x)$, $R_y = \text{rank}(y)$
2. Aplicar a fórmula de Pearson sobre os ranks:

$$r_s = \frac{\sum (R_{x_i} - \bar{R}_x)(R_{y_i} - \bar{R}_y)}{\sqrt{\sum(R_{x_i} - \bar{R}_x)^2 \cdot \sum(R_{y_i} - \bar{R}_y)^2}}$$

**Validação:** comparado com `cor(x, y, method = "spearman")` do R.

#### Interpretação da Diferença Pearson vs Spearman

- Se $r_P \approx r_S$: a relação linear captura bem a associação; dados sem outliers influentes
- Se $r_S > r_P$: a relação é monotônica mas não exatamente linear, ou outliers estão atenuando $r_P$
- Se $r_S < r_P$: situação menos comum; pode indicar relação linear instável

---

### 5.5 Tabela Final de Correlações

Gerada e salva em `output/tabelas/tabela_correlacoes.csv`:

| Variável      | Pearson ($r$) | Spearman ($r_s$) | p-value | IC 95% Li | IC 95% Ls |
| ------------- | ------------- | ---------------- | ------- | --------- | --------- |
| PETR4 × IBOV  | —             | —                | —       | —         | —         |
| PETR4 × BRENT | —             | —                | —       | —         | —         |
| PETR4 × DOLAR | —             | —                | —       | —         | —         |

---

## 6. Etapa 4 — Regressão Linear (R)

**Arquivo:** `R/04_regressao.R`
**Pacotes:** `tidyverse`, `ggplot2`, `car`, `lmtest`, `nortest`

### 6.1 Modelo

**Regressão linear múltipla:**

$$Y = \beta_0 + \beta_1 X_1 + \beta_2 X_2 + \beta_3 X_3 + \varepsilon$$

Onde:

- $Y$ = `retorno_petr4`
- $X_1$ = `retorno_ibov`
- $X_2$ = `retorno_brent`
- $X_3$ = `retorno_dolar`
- $\varepsilon \sim N(0, \sigma^2)$ — termo de erro aleatório

---

### 6.2 Método dos Mínimos Quadrados (MQO) — Álgebra Matricial

O estimador de MQO minimiza a soma dos quadrados dos resíduos:

$$\hat{\boldsymbol{\beta}} = \arg\min_{\boldsymbol{\beta}} \|\mathbf{y} - \mathbf{X}\boldsymbol{\beta}\|^2$$

A solução analítica (equações normais) é:

$$\hat{\boldsymbol{\beta}} = (\mathbf{X}'\mathbf{X})^{-1}\mathbf{X}'\mathbf{y}$$

Onde:

- $\mathbf{X}$ é a matriz de design $(n \times 4)$, com coluna de 1s para o intercepto
- $\mathbf{y}$ é o vetor $(n \times 1)$ dos retornos de PETR4
- $(\mathbf{X}'\mathbf{X})^{-1}$ é calculado com `solve()` no R

**Valores ajustados:** $\hat{\mathbf{y}} = \mathbf{X}\hat{\boldsymbol{\beta}}$

**Resíduos:** $\mathbf{e} = \mathbf{y} - \hat{\mathbf{y}}$

**Validação:** os coeficientes são comparados com `lm()` do R (tolerância $< 10^{-6}$).

---

### 6.3 Erros Padrão dos Coeficientes

A **variância do erro** é estimada por:

$$\hat{\sigma}^2 = \frac{SQRes}{n - k} = \frac{\mathbf{e}'\mathbf{e}}{n - k}$$

Onde $k = 4$ (intercepto + 3 regressores).

A **matriz de covariância** dos estimadores é:

$$\text{Cov}(\hat{\boldsymbol{\beta}}) = \hat{\sigma}^2 (\mathbf{X}'\mathbf{X})^{-1}$$

Os **erros padrão** são as raízes quadradas dos elementos diagonais:

$$EP(\hat{\beta}_i) = \sqrt{[\hat{\sigma}^2 (\mathbf{X}'\mathbf{X})^{-1}]_{ii}}$$

---

### 6.4 Testes t dos Coeficientes

Para cada coeficiente:

$$H_0: \beta_i = 0 \quad \text{(variável não contribui para o modelo)}$$
$$H_1: \beta_i \neq 0$$

**Estatística de teste:**

$$t_i = \frac{\hat{\beta}_i}{EP(\hat{\beta}_i)}$$

Sob $H_0$, $t_i \sim t(n - k)$.

- **p-value:** `2 * pt(-abs(t_i), df = n-k)`
- **Decisão:** rejeita $H_0$ se $p < 0{,}05$

---

### 6.5 Coeficiente de Determinação R²

Mede a proporção da variação total de $Y$ explicada pelo modelo:

$$R^2 = \frac{SQReg}{SQTotal} = 1 - \frac{SQRes}{SQTotal}$$

Onde:

- $SQTotal = \sum_{i=1}^n (y_i - \bar{y})^2$ — variação total de $Y$
- $SQReg = \sum_{i=1}^n (\hat{y}_i - \bar{y})^2$ — variação explicada pelo modelo
- $SQRes = \sum_{i=1}^n e_i^2$ — variação residual (não explicada)

**Relação fundamental:**

$$SQTotal = SQReg + SQRes$$

#### R² Ajustado

Penaliza a adição de variáveis irrelevantes:

$$R^2_{\text{adj}} = 1 - \frac{SQRes/(n-k)}{SQTotal/(n-1)}$$

---

### 6.6 ANOVA da Regressão

Testa a significância global do modelo:

$$H_0: \beta_1 = \beta_2 = \beta_3 = 0 \quad \text{(modelo não tem poder explicativo)}$$
$$H_1: \text{pelo menos um } \beta_i \neq 0$$

| Fonte     | SQ        | GL        | QM                    | F                 |
| --------- | --------- | --------- | --------------------- | ----------------- |
| Regressão | $SQReg$   | $k-1 = 3$ | $QMReg = SQReg/(k-1)$ | $F = QMReg/QMRes$ |
| Resíduo   | $SQRes$   | $n-k$     | $QMRes = SQRes/(n-k)$ | —                 |
| Total     | $SQTotal$ | $n-1$     | —                     | —                 |

**Estatística F:**

$$F = \frac{QMReg}{QMRes} \sim F(k-1,\; n-k) \quad \text{sob } H_0$$

- **Valor crítico:** $F_{\text{crit}} = F_{0{,}05;\; k-1;\; n-k}$ via `qf(0.95, ...)`
- **p-value:** `pf(F_calc, df1 = k-1, df2 = n-k, lower.tail = FALSE)`
- **Decisão:** rejeita $H_0$ se $F_{\text{calc}} > F_{\text{crit}}$

---

### 6.7 Diagnóstico dos Resíduos

#### 6.7.1 Histograma dos Resíduos

Visualiza a distribuição dos resíduos sobreposta com curva de densidade. Permite avaliar visualmente a simetria e a aproximação à normalidade.

- Implementado com `ggplot2::geom_histogram()` + `geom_density()`

#### 6.7.2 QQ Plot dos Resíduos

Compara os quantis dos resíduos com os quantis da normal teórica. Desvios sistemáticos da linha de referência indicam violação da normalidade.

- Implementado com `qqnorm()` e `qqline()` do R base

#### 6.7.3 Resíduos vs Valores Ajustados

Gráfico de dispersão dos resíduos $e_i$ contra os valores ajustados $\hat{y}_i$:

- **Homocedasticidade:** os resíduos devem estar dispersos aleatoriamente em torno de zero, sem padrão de funil
- **Linearidade:** sem curvatura sistemática na dispersão
- Curva suavizada (LOESS) adicionada para detecção visual de padrões

#### 6.7.4 Teste de Shapiro-Wilk nos Resíduos

Testa formalmente a normalidade dos resíduos (pressuposto do modelo):

$$H_0: \varepsilon \sim N(0, \sigma^2)$$

Função R: `shapiro.test(residuals(modelo))`

#### 6.7.5 Teste de Breusch-Pagan (Homocedasticidade)

Testa se a variância dos resíduos é constante (homocedasticidade):

$$H_0: \text{variância dos resíduos é constante (homocedasticidade)}$$
$$H_1: \text{variância dos resíduos varia com as variáveis explicativas (heterocedasticidade)}$$

O teste ajusta uma regressão auxiliar dos resíduos quadráticos contra os regressores originais. Estatística: $BP = n \cdot R^2_{\text{aux}} \sim \chi^2(k-1)$.

- Função R: `lmtest::bptest(modelo)`

#### 6.7.6 Fator de Inflação da Variância (VIF)

Detecta multicolinearidade entre os regressores:

$$VIF_j = \frac{1}{1 - R^2_j}$$

Onde $R^2_j$ é o $R^2$ da regressão de $X_j$ contra os demais regressores.

- $VIF < 5$: multicolinearidade aceitável
- $VIF > 10$: multicolinearidade severa — estimadores instáveis

- Função R: `car::vif(modelo)`

---

## 7. Pacotes Utilizados

### Python

| Pacote     | Versão recomendada | Uso                                           |
| ---------- | ------------------ | --------------------------------------------- |
| `yfinance` | ≥ 0.2              | Download de dados históricos do Yahoo Finance |
| `pandas`   | ≥ 1.5              | Manipulação de DataFrames e séries temporais  |
| `numpy`    | ≥ 1.23             | Operações numéricas auxiliares                |

### R

| Pacote      | Uso                                                      |
| ----------- | -------------------------------------------------------- |
| `tidyverse` | Manipulação de dados (`dplyr`, `tidyr`) e leitura de CSV |
| `ggplot2`   | Gráficos de dispersão, histogramas, diagnósticos         |
| `psych`     | Estatísticas descritivas avançadas                       |
| `car`       | VIF (Fator de Inflação da Variância)                     |
| `lmtest`    | Teste de Breusch-Pagan                                   |
| `nortest`   | Testes de normalidade (Anderson-Darling)                 |

---

## 8. Outputs Gerados

### Tabelas (`output/tabelas/`)

| Arquivo                        | Conteúdo                                             |
| ------------------------------ | ---------------------------------------------------- |
| `estatisticas_descritivas.csv` | Média, mediana, DP, mín, máx, CV por variável        |
| `shapiro_wilk.csv`             | Estatística W e p-value do Shapiro-Wilk por variável |
| `tabela_correlacoes.csv`       | Pearson, Spearman, p-value, IC 95% para cada par     |
| `coeficientes_regressao.csv`   | β estimados, EP, t, p-value, significância           |
| `anova_regressao.csv`          | SQTotal, SQReg, SQRes, GL, QM, F, p-value            |
| `diagnostico_residuos.csv`     | Shapiro-Wilk e Breusch-Pagan nos resíduos            |

### Gráficos (`output/graficos/`)

| Arquivo                             | Conteúdo                            |
| ----------------------------------- | ----------------------------------- |
| `qqplot_retorno_petr4.png`          | QQ Plot — PETR4                     |
| `qqplot_retorno_ibov.png`           | QQ Plot — IBOV                      |
| `qqplot_retorno_brent.png`          | QQ Plot — Brent                     |
| `qqplot_retorno_dolar.png`          | QQ Plot — Dólar                     |
| `dispersao_petr4_retorno_ibov.png`  | PETR4 × IBOV com reta de regressão  |
| `dispersao_petr4_retorno_brent.png` | PETR4 × Brent com reta de regressão |
| `dispersao_petr4_retorno_dolar.png` | PETR4 × Dólar com reta de regressão |
| `hist_residuos.png`                 | Histograma dos resíduos do modelo   |
| `qqplot_residuos.png`               | QQ Plot dos resíduos do modelo      |
| `residuos_vs_ajustados.png`         | Resíduos vs Valores Ajustados       |

---

## Referências Metodológicas

- **Correlação de Pearson:** PEARSON, K. (1895). Notes on regression and inheritance in the case of two parents. _Proceedings of the Royal Society of London_, 58, 240-242.
- **Transformação Z de Fisher:** FISHER, R. A. (1915). Frequency distribution of the values of the correlation coefficient in samples from an indefinitely large population. _Biometrika_, 10(4), 507-521.
- **Correlação de Spearman:** SPEARMAN, C. (1904). The proof and measurement of association between two things. _American Journal of Psychology_, 15(1), 72-101.
- **MQO — Gauss-Markov:** GAUSS, C. F. (1809). _Theoria Motus Corporum Coelestium_. MARKOV, A. A. (1900). _Wahrscheinlichkeitsrechnung_.
- **Teste de Breusch-Pagan:** BREUSCH, T. S.; PAGAN, A. R. (1979). A simple test for heteroscedasticity and random coefficient variation. _Econometrica_, 47(5), 1287-1294.
- **VIF:** MARQUARDT, D. W. (1970). Generalized inverses, ridge regression, biased linear estimation, and nonlinear estimation. _Technometrics_, 12(3), 591-612.
