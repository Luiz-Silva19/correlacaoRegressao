# Projeto de Correlação e Regressão Linear

## Análise do Impacto Conjunto do Ibovespa, do Petróleo Brent e do Dólar sobre os Retornos da PETR4

# Objetivo do Projeto

Desenvolver um estudo estatístico utilizando técnicas de Correlação e Regressão Linear para investigar a influência conjunta do Ibovespa, do Petróleo Brent e da taxa de câmbio Dólar/Real sobre os retornos da ação PETR4.

O trabalho deve seguir rigorosamente os conceitos abordados na disciplina de Correlação e Regressão Linear, utilizando dados reais de mercado financeiro.

---

# Problema de Pesquisa

O retorno da ação PETR4 possui relação estatisticamente significativa com o Ibovespa, o Petróleo Brent e o Dólar?

Entre esses fatores, qual exerce maior influência sobre os retornos da PETR4?

---

# Objetivo Geral

Avaliar a influência conjunta do Ibovespa, do Petróleo Brent e do Dólar sobre os retornos da PETR4 por meio de técnicas de Correlação e Regressão Linear.

---

# Arquitetura da Solução

O projeto será dividido em duas etapas:

## Etapa 1 - Python

Responsável exclusivamente pela obtenção dos dados.

Funções:

- Download dos dados históricos.
- Tratamento mínimo para consolidação.
- Cálculo dos retornos mensais.
- Exportação para CSV.

Saída:

dados_mercado.csv

---

## Etapa 2 - R

Responsável por toda a análise estatística.

O código deverá ser dividido em três scripts independentes.

---

# Estrutura do Projeto

/projeto-correlacao-regressao

/data
dados_mercado.csv

/python
01_coleta_dados.py

/R
02_sanitizacao.R
03_correlacao.R
04_regressao.R

/output
tabelas/
graficos/
relatorios/

---

# Script Python

Arquivo:

01_coleta_dados.py

Objetivo:

Realizar download dos dados históricos utilizando Yahoo Finance.

Ativos:

PETR4.SA
^BVSP
BZ=F (Brent)
BRL=X (Dólar)

Período:

01/07/2021 até 30/06/2026

Frequência:

Mensal

---

# Processamento Python

Utilizar preço ajustado.

Calcular:

Retorno (%) = ((Preço Atual - Preço Anterior) / Preço Anterior) \* 100

Gerar:

data
retorno_petr4
retorno_ibov
retorno_brent
retorno_dolar

Exportar:

data/dados_mercado.csv

Nenhuma análise estatística deverá ser realizada em Python.

Python será utilizado apenas para aquisição e preparação dos dados.

---

# Script R - Sanitização

Arquivo:

02_sanitizacao.R

Objetivo:

Preparar os dados para análise estatística.

Atividades:

- Ler CSV gerado pelo Python.
- Verificar valores ausentes.
- Verificar inconsistências.
- Remover registros inválidos.
- Verificar duplicidades.
- Gerar estatísticas descritivas.

Para cada variável:

- Média
- Mediana
- Desvio padrão
- Mínimo
- Máximo
- Coeficiente de variação

Gerar tabelas para relatório.

Salvar dataset tratado.

---

# Script R - Correlação

Arquivo:

03_correlacao.R

Objetivo:

Aplicar todas as técnicas de correlação estudadas na disciplina.

Variáveis analisadas:

PETR4 × IBOV

PETR4 × BRENT

PETR4 × DOLAR

---

# Verificação dos Pressupostos

Gerar:

QQ Plot para todas as variáveis.

Aplicar:

Teste de Shapiro-Wilk.

Justificar a escolha entre Pearson e Spearman.

---

# Correlação de Pearson

Implementar:

## Forma 1

Escores Padronizados (Z-score)

## Forma 2

Desvios em Relação à Média

## Forma 3

Somas Brutas

Validar que os resultados são equivalentes.

Comparar com cor() do R.

---

# Inferência para Pearson

Para cada correlação:

H0: ρ = 0

H1: ρ ≠ 0

Calcular:

- Estatística t
- Graus de liberdade
- Valor crítico
- p-value

Interpretar resultados.

---

# Intervalo de Confiança

Construir IC de 95% utilizando a Transformação Z de Fisher.

Apresentar:

- Limite inferior
- Limite superior

Interpretar resultado.

---

# Correlação de Spearman

Calcular:

rs

Comparar com implementação nativa do R.

Interpretar diferenças entre Pearson e Spearman.

---

# Entregáveis da Correlação

Tabela contendo:

Variável
Pearson
Spearman
p-value
IC 95%

Exemplo:

PETR4 x IBOV
PETR4 x BRENT
PETR4 x DOLAR

---

# Script R - Regressão Linear

Arquivo:

04_regressao.R

Objetivo:

Avaliar a influência conjunta das variáveis explicativas sobre o retorno da PETR4.

---

# Modelo

Variável Dependente:

Y = retorno_petr4

Variáveis Independentes:

X1 = retorno_ibov

X2 = retorno_brent

X3 = retorno_dolar

Modelo:

Y = β0 + β1(X1) + β2(X2) + β3(X3) + ε

---

# Método dos Mínimos Quadrados

Apresentar:

- Coeficientes estimados
- Interpretação econômica
- Erros padrão

---

# Testes dos Coeficientes

Para cada β:

H0: βi = 0

H1: βi ≠ 0

Apresentar:

- Estatística t
- p-value

Interpretar significância.

---

# Qualidade do Modelo

Calcular:

R²

R² Ajustado

Interpretar:

Percentual da variação dos retornos da PETR4 explicado pelo modelo.

---

# ANOVA da Regressão

Apresentar:

- SQTotal
- SQReg
- SQRes

Validar:

SQTotal = SQReg + SQRes

Realizar teste F global do modelo.

---

# Diagnóstico dos Resíduos

Gerar:

- Histograma dos resíduos
- QQ Plot dos resíduos
- Resíduos versus Ajustados

Avaliar:

- Normalidade
- Homocedasticidade
- Independência visual

---

# Resultados Esperados

O projeto deve responder:

1. Existe correlação significativa entre PETR4 e os fatores analisados?

2. Qual fator possui maior correlação com PETR4?

3. Quais fatores apresentam influência estatisticamente significativa na regressão?

4. Qual fator possui maior impacto sobre os retornos da PETR4?

5. Quanto da variabilidade dos retornos da PETR4 é explicada pelo modelo?

---

# Requisitos

Python:

- pandas
- numpy
- yfinance

R:

- tidyverse
- ggplot2
- psych
- car
- lmtest
- nortest

Todos os cálculos apresentados na disciplina devem ser implementados explicitamente sempre que possível e posteriormente validados pelas funções nativas do R.
