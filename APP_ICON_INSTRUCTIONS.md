# Instruções para Adicionar o Ícone do Globo

## Como adicionar o ícone da aplicação

O projeto está configurado para aceitar um ícone de aplicação. Para adicionar o ícone do globo:

### Opção 1: Criar um ícone personalizado

1. Crie ou obtenha uma imagem PNG de um globo terrestre com 1024x1024 pixels
2. No Xcode, navegue até: `earthQuiz/Assets.xcassets/AppIcon.appiconset/`
3. Arraste a imagem para o slot "App Icon" no Xcode
4. O Xcode irá gerar automaticamente todos os tamanhos necessários

### Opção 2: Usar um gerador online

1. Visite um site como:
   - https://www.appicon.co/
   - https://appicon.build/
   - https://makeappicon.com/

2. Faça upload de uma imagem de globo (mínimo 1024x1024px)

3. Baixe o conjunto de ícones gerado

4. No Xcode, arraste todos os arquivos para `AppIcon.appiconset`

### Opção 3: Usar SF Symbols (temporário)

Se precisar de um ícone placeholder enquanto cria o final:

1. Abra o aplicativo SF Symbols no Mac
2. Procure por "globe" ou "globe.americas" ou "globe.europe.africa"
3. Exporte como imagem de alta resolução
4. Redimensione para 1024x1024px
5. Adicione ao projeto

### Requisitos do Ícone

- Formato: PNG
- Tamanho: 1024x1024 pixels
- Sem transparência (use fundo sólido)
- Sem cantos arredondados (o iOS adiciona automaticamente)
- Boa margem interna (evite elementos nas bordas)

### Sugestões de Design

Para um ícone de globo profissional:
- Use um gradiente azul-verde para representar a Terra
- Adicione continentes estilizados
- Mantenha o design simples e reconhecível
- Use cores que combinem com o tema da app (azul/roxo)

## Localização dos Arquivos

O ícone deve ser adicionado em:
```
earthQuiz/Assets.xcassets/AppIcon.appiconset/
```

Após adicionar, o arquivo `Contents.json` será atualizado automaticamente pelo Xcode.
