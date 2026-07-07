# M-Westy ClothID

Ferramenta para FiveM desenvolvida para capturar os IDs de roupas e acessórios do personagem em tempo real. Ideal para desenvolvedores de servidores, designers de roupas e administradores configurarem presets ou scripts de customização visual.


## 🚀 Recursos

* **Câmera integrada:** Foco inteligente em partes específicas do corpo (Cabeça, Torso, Pernas, Sapatos ou Corpo Inteiro), com controle manual de rotação e zoom.
* **Cópia rápida:** Exportação instantânea dos IDs das roupas em formato de tabela Lua ou JSON diretamente para a área de transferência.
* **Alternar Gênero:** Botão para alternar entre os modelos masculino e feminino (`mp_m_freemode_01` e `mp_f_freemode_01`) diretamente no painel.
* **Compatibilidade:** Integração nativa com o menu radial/dinâmico (`dynamic`).

## 🛠️ Comandos

No chat do jogo ou console, utilize qualquer um dos comandos abaixo para abrir a interface:

* `/clothid`
* `/roupaid`

## ⚙️ Instalação

1. Cole a pasta `M-Westy_ClothID` no diretório de resources do seu servidor.
2. Certifique-se de manter o arquivo `README-NÃO-EXCLUA.md` e `server-side/credits.lua` intactos (o script possui verificação automática de assinatura desses arquivos).
3. Adicione `ensure M-Westy_ClothID` no arquivo `server.cfg`.

## 📦 Exemplo de Dados Exportados (Lua)

```lua
["mp_m_freemode_01"] = {
    ["hat"] = { item = 0, texture = 0 },
    ["pants"] = { item = 4, texture = 0 },
    ["arms"] = { item = 15, texture = 0 },
    ["tshirt"] = { item = 15, texture = 0 },
    ["torso"] = { item = 11, texture = 0 },
    ["vest"] = { item = 0, texture = 0 },
    ["shoes"] = { item = 6, texture = 0 },
    ["mask"] = { item = 0, texture = 0 },
    ["backpack"] = { item = 0, texture = 0 },
    ["glass"] = { item = 0, texture = 0 },
    ["ear"] = { item = 0, texture = 0 },
    ["watch"] = { item = 0, texture = 0 },
    ["bracelet"] = { item = 0, texture = 0 },
    ["accessory"] = { item = 0, texture = 0 },
    ["decals"] = { item = 0, texture = 0 }
}
```
