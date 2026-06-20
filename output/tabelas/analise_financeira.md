# Análise Financeira dos Resultados de Correlação e Regressão

## Base analisada

- Amostra mensal com **50 observações** em `data/dados_tratados.csv`
- Variável resposta: **retorno_petr4**
- Variáveis explicativas: **retorno_ibov**, **retorno_brent** e **retorno_dolar**

## Faz sentido aplicar correlação e regressão neste caso?

**Sim, faz sentido estatisticamente e financeiramente.**

Do ponto de vista financeiro, a PETR4 tende a reagir a:

- **Ibovespa**, porque a ação faz parte do mercado acionário brasileiro e acompanha o humor geral da bolsa;
- **Brent**, porque Petrobras é diretamente ligada ao setor de petróleo;
- **Dólar**, porque câmbio afeta preços, receitas externas, percepção de risco e fluxo de capital.

Do ponto de vista estatístico:

- a **correlação** mede a intensidade e a direção da associação entre duas variáveis;
- a **regressão múltipla** mede o efeito de cada fator **controlando os demais**.

Ou seja: a correlação responde se as variáveis se movem juntas; a regressão responde quanto cada uma ajuda a explicar o retorno da PETR4 quando analisadas em conjunto.

## O que a análise de correlação está dizendo

Resultados de `output/tabelas/tabela_correlacoes.csv`:

| Relação | Pearson | Spearman | p-valor |
|---|---:|---:|---:|
| PETR4 x IBOV | 0,3903 | 0,3436 | 0,0051 |
| PETR4 x BRENT | 0,2929 | 0,3588 | 0,0390 |
| PETR4 x DÓLAR | -0,1201 | -0,0798 | 0,4060 |

### Interpretação

1. **PETR4 x IBOV**  
   Há **correlação positiva moderada e estatisticamente significativa**. Quando o mercado sobe, PETR4 tende a subir também. É o vínculo bivariado mais claro da amostra.

2. **PETR4 x BRENT**  
   Há **correlação positiva fraca a moderada e significativa**. Isso é coerente com o negócio da Petrobras: melhora no petróleo tende a favorecer a ação.

3. **PETR4 x DÓLAR**  
   A correlação é **fraca, negativa e não significativa**. Isoladamente, o dólar não mostrou relação linear consistente com PETR4 nesta amostra.

## Pearson ou Spearman?

Resultados de `output/tabelas/shapiro_wilk.csv`:

- **retorno_petr4**: normal
- **retorno_ibov**: normal
- **retorno_brent**: **não normal**
- **retorno_dolar**: normal

Como o **Brent rejeitou normalidade**, faz sentido reportar **Pearson e Spearman**.

- **Pearson** avalia associação **linear**;
- **Spearman** avalia associação **monotônica**, sendo mais robusto a assimetria e desvios de normalidade.

Logo, a decisão metodológica está correta: usar Pearson como medida principal de linearidade e Spearman como verificação complementar.

## O que a regressão está dizendo

Modelo analisado:

`retorno_petr4 ~ retorno_ibov + retorno_brent + retorno_dolar`

Resultados estimados com base em `data/dados_tratados.csv`, seguindo a especificação de `R/04_regressao.R`:

| Variável | Coeficiente | p-valor | Interpretação |
|---|---:|---:|---|
| Intercepto | 1,7217 | 0,1671 | sem significância estatística |
| IBOV | 1,1260 | 0,0005 | efeito positivo e forte |
| BRENT | 0,2781 | 0,0083 | efeito positivo |
| DÓLAR | 1,0835 | 0,0333 | efeito positivo condicional |

### Interpretação estatística

- **R² = 0,3027**  
  O modelo explica cerca de **30,27%** da variação dos retornos da PETR4.

- **R² ajustado = 0,2572**  
  Após penalizar a quantidade de variáveis, a explicação cai para **25,72%**, mostrando poder explicativo **moderado**.

- **Teste F global: p = 0,0008**  
  O conjunto das variáveis é **estatisticamente relevante** para explicar PETR4.

### Interpretação econômica

- **IBOV** é o fator mais importante do modelo. Em média, uma alta de **1%** no Ibovespa está associada a uma alta de aproximadamente **1,13%** em PETR4, mantendo Brent e Dólar constantes.
- **BRENT** também contribui positivamente. Uma alta de **1%** no Brent está associada a cerca de **0,28%** de alta em PETR4, controlando os demais fatores.
- **DÓLAR** aparece com **coeficiente positivo na regressão**, apesar de a correlação simples ter sido fraca e negativa.

## Como explicar a diferença entre correlação e regressão no dólar

Isso não é um erro estatístico.

A **correlação** olha o dólar **sozinho** contra PETR4.  
A **regressão múltipla** olha o dólar **junto com IBOV e Brent**.

Portanto, o resultado sugere que:

- isoladamente, o dólar não tem relação linear forte com PETR4;
- mas, **condicionando pelos movimentos do mercado e do petróleo**, o dólar passa a carregar informação adicional relevante.

Esse tipo de mudança de sinal pode ocorrer por efeito de composição entre variáveis explicativas.

## Diagnóstico do modelo

Os diagnósticos também sustentam o uso da regressão:

- **Resíduos com normalidade aceitável**: Shapiro-Wilk **p = 0,6391**
- **Sem evidência de heterocedasticidade**: Breusch-Pagan **p = 0,2564**
- **Sem multicolinearidade severa**: VIFs entre **1,08** e **1,93**

Isso indica que os pressupostos principais do modelo linear estão razoavelmente atendidos para esta base.

## Conclusão final

A análise **faz sentido** e os resultados contam uma história coerente:

1. **PETR4 acompanha o mercado**: o Ibovespa foi o fator mais consistente.
2. **PETR4 também responde ao petróleo**: Brent mostrou relação positiva relevante.
3. **O dólar, sozinho, não foi importante na correlação**, mas ganhou relevância no modelo conjunto.
4. **A regressão é útil, mas não esgota a explicação**: cerca de 70% da variação da PETR4 ainda depende de outros fatores não incluídos no modelo.

Em resumo, a correlação mostra **associação** e a regressão mostra **influência condicional**. Para esta amostra, a principal mensagem estatística é que o retorno da PETR4 é explicado principalmente pelo comportamento do **Ibovespa**, com contribuição adicional do **Brent** e um efeito cambial que só aparece de forma mais clara quando os fatores são analisados em conjunto.
