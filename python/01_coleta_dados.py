"""
01_coleta_dados.py
------------------
Coleta dados históricos mensais de PETR4, IBOV, Brent e Dólar via Yahoo Finance.
Calcula retornos mensais e exporta para data/dados_mercado.csv.

Nenhuma análise estatística é realizada neste script.
"""

import pandas as pd
import numpy as np
import yfinance as yf
import os

# ---------------------------------------------------------------------------
# Configurações
# ---------------------------------------------------------------------------

ATIVOS = {
    "petr4":  "PETR4.SA",
    "ibov":   "^BVSP",
    "brent":  "BZ=F",
    "dolar":  "BRL=X",
}

DATA_INICIO = "2021-07-01"
DATA_FIM    = "2026-06-30"
INTERVALO   = "1mo"

BASE_DIR   = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTPUT_CSV = os.path.join(BASE_DIR, "data", "dados_mercado.csv")

# ---------------------------------------------------------------------------
# Funções
# ---------------------------------------------------------------------------

def baixar_serie(ticker: str, inicio: str, fim: str, intervalo: str) -> pd.Series:
    """Baixa o preço ajustado de fechamento de um ativo via yfinance."""
    dados = yf.download(
        ticker,
        start=inicio,
        end=fim,
        interval=intervalo,
        auto_adjust=True,   # já retorna preço ajustado em 'Close'
        progress=False,
    )
    if dados.empty:
        raise ValueError(f"Nenhum dado retornado para o ticker '{ticker}'.")

    # yfinance pode retornar MultiIndex quando auto_adjust=True
    if isinstance(dados.columns, pd.MultiIndex):
        preco = dados["Close"].squeeze()
    else:
        preco = dados["Close"]

    preco.name = ticker
    return preco


def calcular_retorno(preco: pd.Series) -> pd.Series:
    """Calcula o retorno percentual mensal: ((P_t - P_{t-1}) / P_{t-1}) * 100."""
    retorno = ((preco - preco.shift(1)) / preco.shift(1)) * 100
    retorno.name = preco.name
    return retorno


def normalizar_index(serie: pd.Series) -> pd.Series:
    """Normaliza o índice para o primeiro dia do mês (YYYY-MM-01)."""
    serie.index = serie.index.to_period("M").to_timestamp()
    return serie


# ---------------------------------------------------------------------------
# Pipeline principal
# ---------------------------------------------------------------------------

def main():
    print("=== Coleta de Dados de Mercado ===\n")

    series_retorno = {}

    for nome, ticker in ATIVOS.items():
        print(f"Baixando dados de {ticker} ({nome})...")
        preco   = baixar_serie(ticker, DATA_INICIO, DATA_FIM, INTERVALO)
        print(preco.index)
        print(preco.to_frame().tail(60))
        preco   = normalizar_index(preco)
        retorno = calcular_retorno(preco)
        series_retorno[f"retorno_{nome}"] = retorno
        print(f"  Observações brutas: {len(preco)} | Retornos calculados: {retorno.notna().sum()}")

    print("\nConsolidando séries...")

    df = pd.DataFrame(series_retorno)
    print("\nValores ausentes por coluna:")
    print(df.isna().sum())

    print("\nLinhas com Brent nulo:")
    print(df[df["retorno_brent"].isna()])

    # Remove a primeira linha (sempre NaN por conta do shift)
    df = df.dropna(how="all")

    # Renomeia índice para 'data'
    df.index.name = "data"
    df = df.reset_index()
    df["data"] = df["data"].dt.strftime("%Y-%m-%d")

    # Reordena colunas conforme especificação
    df = df[["data", "retorno_petr4", "retorno_ibov", "retorno_brent", "retorno_dolar"]]

    print(f"Linhas após remoção de NaN iniciais: {len(df)}")
    print("\nPrimeiras linhas:")
    print(df.head())
    print("\nÚltimas linhas:")
    print(df.tail())

    # Exporta CSV
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)
    df.to_csv(OUTPUT_CSV, index=False, float_format="%.6f")
    print(f"\nArquivo exportado: {OUTPUT_CSV}")
    print("=== Coleta concluída com sucesso ===")


if __name__ == "__main__":
    main()
