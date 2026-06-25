# 🪙 CryptoWallet

O **CryptoWallet** é um aplicativo iOS nativo focado no gerenciamento e na simulação de um portfólio de criptomoedas. O projeto permite que os usuários criem contas de forma local, acompanhem o saldo de seus investimentos, visualizem cotações e gráficos em tempo real através da integração com a API da Binance, e realizem operações de compra e venda de ativos digitais utilizando o Real (R$) como moeda base.

## 👥 Integrantes
- Gabrielle Alves de Almeida
- Gabriela de Souza
- Lucas Peres Moreira
- Márcio Soares
- Melyssa Gleyce Dutra Carvalho
- Pedro Henrique Nieto da Silva

## 🧩 Protótipo e Demonstação

### 🎨 Design das telas
[Clique aqui para ver o Figma](https://www.figma.com/design/ivHDPkElFD4IhTkqQ1iVYr/Projeto-IOS?node-id=1-4223&p=f&t=8I0vez4AnafAvfhJ-0)

### 📱 Fluxo de Navegação
[Assista à demonstração em vídeo](video/Gravação%20de%20Tela%202026-06-25%20às%2018.07.27.mov)



## ✨ Funcionalidades

### 🔐 Autenticação
* **Cadastro:** Criação de conta informando Nome, E-mail e Senha.
* **Login:** Acesso ao aplicativo validando E-mail e Senha.

### 🏠 Wallet Home
* **Visão Geral:** Exibição do valor total investido pelo usuário na plataforma.
* **Ações Rápidas:** Botões em destaque para **Buy** (Compra) e **Sell** (Venda), redirecionando para as respectivas telas.
* **Portfólio (Minhas Moedas):** Seção dedicada à exibição dos ativos que o usuário já possui.
* **Mercado (Todas as Moedas):** Lista contendo as criptomoedas disponíveis para visualização e negociação.

### 📈 Dashboard da Moeda
* Tela de detalhes acessada ao tocar em qualquer moeda na *Wallet Home*.
* **Gráfico em Tempo Real:** Acompanhamento das flutuações de preço consumindo os dados da API da Binance.
* **Informações do Ativo:** Dados detalhados e status atual da criptomoeda selecionada.
* **Ação de Compra:** Botão posicionado na parte inferior para adquirir a moeda, redirecionando o usuário para a tela de Compra com o ativo já selecionado.

### 💱 Operações (Compra e Venda)
* Seleção intuitiva da criptomoeda desejada.
* Campo para digitação da quantidade que deseja comprar ou vender, calculada em Reais (R$).
* Confirmação da transação com validação de saldo/quantidade.
* Exibição de alerta informando o sucesso da compra ou venda após a confirmação.

## 🛠️ Tecnologias Utilizadas
* **Linguagem:** Swift
* **Framework** SwiftUI
* **Arquitetura:** MVVM (Model-View-ViewModel) para garantir uma separação clara de responsabilidades, facilitando a manutenção e testes.
* **Persistência de Dados:** CoreData (responsável por armazenar localmente os dados de usuários, saldos, carteiras e histórico).
* **Integração de Dados:** API da Binance (utilizada para buscar dados de mercado e renderizar o gráfico em tempo real).

## 🚀 Instruções de Execução

### Pré-requisitos
* macOS com **Xcode** instalado (versão 14.0 ou superior recomendada).
* Conexão ativa com a internet (necessária para as requisições à API da Binance).

### Passos para rodar o projeto localmente
1. Clone este rIntegração de Dados: API da Binance (utilizada para buscar dados de mercado e renderizar o gráfico em tempo real).
epositório para a sua máquina local:
   ```bash
   git clone [https://github.com/lucasperesm/CryptoWalletFake.git](https://github.com/lucasperesm/CryptoWalletFake.git)
   ```
2. Pelo terminal, navegue até o projeto:
   ```bash
   cd CryptoWalletFake
   ```
3. Abra o projeto no Xcode (abra o arquivo .xcodeproj ou .xcworkspace caso utilize gerenciadores de dependência como CocoaPods):
   ```bash
   open CryptoWallet.xcodeproj
   ```
4. Aguarde o Xcode indexar os arquivos e resolver possíveis pacotes do Swift Package Manager.

5. Na barra superior do Xcode, selecione um simulador (ex: iPhone 15 Pro) ou conecte seu dispositivo físico.

6. Pressione o botão de Play ou utilize o atalho de teclado:
   ```bash
   Cmd (⌘) + R
   ```
