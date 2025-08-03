# World Flags - App de Perguntas sobre Bandeiras

Um aplicativo educativo em Flutter que testa seu conhecimento sobre bandeiras de países ao redor do mundo.

## 🚀 Funcionalidades

- **Jogo de Perguntas**: Teste seu conhecimento sobre bandeiras de países
- **Múltipla Escolha**: 4 opções por pergunta
- **Sistema de Pontuação**: Acompanhe seu progresso
- **Ranking**: Veja seus melhores scores
- **Interface Moderna**: Design responsivo e intuitivo
- **Dados Reais**: Bandeiras e países reais da API REST Countries

## 🎮 Como Jogar

1. **Inicie o Jogo**: Toque em "Jogar" na tela inicial
2. **Responda as Perguntas**: Escolha qual país cada bandeira representa
3. **Acompanhe o Progresso**: Veja sua pontuação em tempo real
4. **Veja o Resultado**: Confira sua performance no final
5. **Melhore sua Pontuação**: Jogue novamente para melhorar!

## 📱 Telas do App

### Tela Inicial
- Menu principal com opções de jogo
- Informações sobre o app
- Acesso ao ranking

### Tela de Jogo
- Exibição da bandeira do país
- 4 opções de resposta
- Barra de progresso
- Pontuação atual

### Tela de Resultado
- Pontuação final
- Porcentagem de acertos
- Mensagem motivacional
- Opções para jogar novamente

### Tela de Ranking
- Lista dos melhores scores
- Medalhas para os top 3
- Data/hora de cada jogo
- Porcentagem de acertos

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **HTTP**: Para requisições à API
- **Shared Preferences**: Para armazenamento local
- **REST Countries API**: Dados de países e bandeiras

## 📦 Instalação

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/world_flags.git
cd world_flags
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o app:
```bash
flutter run
```

## 🎯 Como Funciona

### Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── models/
│   ├── country.dart         # Modelo de dados do país
│   └── game_state.dart      # Estado do jogo
├── services/
│   └── country_service.dart # Serviço para buscar dados
└── screens/
    ├── home_screen.dart     # Tela inicial
    ├── game_screen.dart     # Tela do jogo
    ├── game_over_screen.dart # Tela de resultado
    └── leaderboard_screen.dart # Tela de ranking
```

### Fluxo do Jogo

1. **Inicialização**: Carrega países da API REST Countries
2. **Seleção**: Escolhe 10 países aleatórios para o jogo
3. **Perguntas**: Para cada país, gera 4 opções (1 correta + 3 aleatórias)
4. **Resposta**: Usuário escolhe uma opção
5. **Feedback**: Mostra se acertou ou errou
6. **Progresso**: Avança para próxima pergunta
7. **Resultado**: Exibe pontuação final e salva no ranking

### API Utilizada

O app utiliza a [REST Countries API](https://restcountries.com/) para obter:
- Nomes dos países
- URLs das bandeiras
- Códigos dos países

## 🎨 Design

- **Tema**: Cores azuis e gradientes modernos
- **Interface**: Material Design 3
- **Responsividade**: Adaptável a diferentes tamanhos de tela
- **Feedback Visual**: Animações e cores para indicar acertos/erros

## 📊 Sistema de Pontuação

- **10 perguntas** por jogo
- **1 ponto** por resposta correta
- **Ranking** com os 10 melhores scores
- **Porcentagem** de acertos calculada automaticamente

## 🔧 Personalização

Você pode personalizar o app modificando:

- **Número de perguntas**: Altere `totalQuestions` em `game_screen.dart`
- **Cores do tema**: Modifique `ColorScheme` em `main.dart`
- **Mensagens**: Edite as strings nas telas
- **API**: Troque a URL da API em `country_service.dart`

## 📱 Compatibilidade

- **Android**: API 21+ (Android 5.0+)
- **iOS**: iOS 11.0+
- **Web**: Navegadores modernos
- **Desktop**: Windows, macOS, Linux

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🙏 Agradecimentos

- [REST Countries API](https://restcountries.com/) pelos dados
- [Flutter](https://flutter.dev/) pelo framework
- [Material Design](https://material.io/) pelo design system

---

**Divirta-se aprendendo sobre as bandeiras do mundo! 🌍🏳️**
