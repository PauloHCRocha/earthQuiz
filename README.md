# 🌍 Earth Quiz - Jogo de Rankings Mundiais

Um jogo interativo para iOS que testa seus conhecimentos sobre rankings mundiais de países em diversas categorias.

## 📱 Sobre o Jogo

Earth Quiz é um jogo educativo e divertido onde você precisa identificar em qual categoria um país tem o melhor ranking mundial.

### Como Jogar

1. **5 categorias aleatórias** são escolhidas no início de cada jogo
2. A cada round, um **país aleatório** é apresentado
3. Você deve **escolher a categoria** em que aquele país tem o melhor ranking (menor número)
4. Sua pontuação é igual à **posição do país no ranking** daquela categoria
5. A categoria escolhida **sai do jogo** no próximo round
6. O jogo continua por **5 rounds** (até todas as categorias serem usadas)

### Objetivo

**Menor pontuação = Melhor resultado!**

Quanto menor a soma das posições de ranking, melhor foi seu desempenho.

## 🎯 Categorias Disponíveis

- 👥 **População** - Ranking de população mundial
- ⚽ **Futebol** - Ranking FIFA
- ✈️ **Turismo** - Ranking de turismo internacional
- 💰 **PIB** - PIB per capita
- 🌳 **Floresta** - Área florestal
- 🗺️ **Área** - Área territorial
- ❤️ **Expectativa de Vida** - Longevidade
- 📚 **Educação** - Qualidade educacional
- 💻 **Tecnologia** - Inovação tecnológica
- ⚡ **Energia Renovável** - Uso de energias limpas

## 🏆 Sistema de Pontuação

- **0-10 pontos médios**: Excepcional! 🏆
- **11-25 pontos médios**: Excelente! ⭐️
- **26-50 pontos médios**: Muito Bom! 👏
- **51-100 pontos médios**: Bom! 👍
- **100+ pontos médios**: Continue praticando! 💪

## 🚀 Recursos

- ✅ Interface moderna em SwiftUI
- ✅ 30+ países com rankings realistas
- ✅ 10 categorias diferentes
- ✅ Sistema de pontuação detalhado
- ✅ Resumo completo ao final do jogo
- ✅ Animações suaves e responsivas
- ✅ Design dark mode elegante

## 📦 Requisitos

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

## 🛠️ Como Executar

1. Clone o repositório
2. Abra `earthQuiz.xcodeproj` no Xcode
3. Selecione um simulador ou dispositivo iOS
4. Pressione `Cmd + R` para compilar e executar

## 📁 Estrutura do Projeto

```
earthQuiz/
├── Models/           # Modelos de dados
│   ├── Category.swift
│   ├── Country.swift
│   └── GameRound.swift
├── ViewModels/       # Lógica do jogo
│   └── GameManager.swift
├── Views/            # Interface SwiftUI
│   ├── ContentView.swift
│   ├── StartView.swift
│   ├── GameView.swift
│   └── GameOverView.swift
└── Data/             # Dados dos países
    └── CountryData.swift
```

## 🎮 Gameplay

### Tela Inicial
- Instruções do jogo
- Botão para iniciar

### Tela de Jogo
- Bandeira e nome do país
- Categorias disponíveis para escolha
- Pontuação atual
- Indicador de round

### Tela de Resultados
- Pontuação total e média
- Avaliação do desempenho
- Resumo de todas as rodadas
- Opções para jogar novamente

## 🌟 Exemplos de Jogabilidade

**Exemplo Round 1:**
- País: Brasil 🇧🇷
- Categorias: População, Futebol, Turismo, PIB, Floresta
- Melhor escolha: Futebol (#1) = 1 ponto

**Exemplo Round 2:**
- País: Suíça 🇨🇭
- Categorias: População, Turismo, PIB, Floresta (Futebol já foi usado)
- Melhor escolha: PIB (#2) = 2 pontos

## 🤝 Contribuições

Sinta-se à vontade para contribuir com:
- Novos países e dados de rankings
- Novas categorias
- Melhorias na UI/UX
- Correções de bugs

## 📄 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

## 👨‍💻 Desenvolvido com

- SwiftUI para interface moderna e reativa
- Combine para gerenciamento de estado
- Arquitetura MVVM para código limpo e manutenível

---

Divirta-se jogando e aprendendo sobre os rankings mundiais! 🌍🎮
