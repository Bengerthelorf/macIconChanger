---
title: Chave de API
section: guide
order: 7
locale: pt
---

Uma chave de API do [macosicons.com](https://macosicons.com/) e necessaria para pesquisar icones online. Sem ela, voce ainda pode usar arquivos de imagem locais.

## Obtendo uma Chave de API

1. Acesse [macosicons.com](https://macosicons.com/) e crie uma conta.
2. Solicite uma chave de API nas configuracoes da sua conta.
3. Copie a chave.

![Como obter uma chave de API](/images/api-key.png)

## Inserindo a Chave

1. Abra o IconChanger.
2. Va em **Settings** > **Advanced**.
3. Cole sua chave de API no campo **API Key**.
4. Clique em **Test Connection** para verificar se funciona.

![Configuracoes da chave de API](/images/api-key-settings.png)

## Usando Sem Chave de API

Voce ainda pode alterar icones de apps sem uma chave de API:

- Usando arquivos de imagem locais (clique em **Choose from the Local** ou arraste e solte uma imagem)
- Usando icones incluidos no proprio app (exibidos na secao "Local")

## Configuracoes Avancadas de API

Em **Settings** > **Advanced** > **API Settings**, voce pode ajustar o comportamento da API:

| Configuracao | Padrao | Descricao |
|---|---|---|
| **Retry Count** | 0 (sem nova tentativa) | Quantas vezes tentar novamente uma solicitacao com falha (0–3) |
| **Timeout** | 15 segundos | Tempo limite por tentativa de solicitacao |
| **Monthly Limit** | 50 | Maximo de consultas de API por mes |

O contador **Monthly Usage** mostra seu uso atual. Ele e redefinido automaticamente no dia 1 de cada mes, ou voce pode redefini-lo manualmente.

### Cache de Pesquisa de Icones

Ative **Cache API Results** para salvar os resultados de pesquisa em disco. Os resultados em cache persistem entre reinicializacoes do app, reduzindo o uso da API. Use o botao de atualizar ao navegar pelos icones para obter resultados atualizados.

## Solucao de Problemas

Se o teste da API falhar:
- Verifique se sua chave esta correta (sem espacos extras)
- Verifique sua conexao com a internet
- A API do macosicons.com pode estar temporariamente indisponivel