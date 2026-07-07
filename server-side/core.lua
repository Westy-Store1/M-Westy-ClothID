local function ValidateLicensing()
    -- 1. VALIDAÇÃO DO README
    local readmeContent = LoadResourceFile(GetCurrentResourceName(), "README-NÃO-EXCLUA.md")
    
    if not readmeContent then
        print("^1[ERRO CRÍTICO] O arquivo README-NÃO-EXCLUA.md foi removido. O recurso M-Westy_ClothID foi interrompido por segurança!^0")
        error("README-NÃO-EXCLUA.md ausente. Execute crash intencional de licenca.")
    end

    local normalizedReadme = string.gsub(readmeContent, "\r\n", "\n")
    local readmeSize = string.len(normalizedReadme)

    if readmeSize < 950 or readmeSize > 1050 then
        print("^1[ERRO CRÍTICO] O arquivo README-NÃO-EXCLUA.md foi alterado ou recriado incorretamente. O recurso M-Westy_ClothID foi interrompido!^0")
        error("README-NÃO-EXCLUA.md tamanho invalido. Execute crash intencional de licenca.")
    end

    local expectedLicenceText = "PROIBIÇÃO DE REVENDA"
    local expectedCopyright = "M-Westy"
    
    if not string.find(normalizedReadme, expectedLicenceText, 1, true) or not string.find(normalizedReadme, expectedCopyright, 1, true) then
        print("^1[ERRO CRÍTICO] A licenca ou autoria oficial de M-Westy foi removida do README-NÃO-EXCLUA.md. O recurso M-Westy_ClothID foi interrompido!^0")
        error("README-NÃO-EXCLUA.md licenca violada. Execute crash intencional de licenca.")
    end

    -- 2. VALIDAÇÃO DO CREDITS.LUA
    local creditsContent = LoadResourceFile(GetCurrentResourceName(), "server-side/credits.lua")
    
    if not creditsContent then
        print("^1[ERRO CRÍTICO] O arquivo server-side/credits.lua foi removido! O recurso M-Westy_ClothID foi interrompido por segurança!^0")
        error("credits.lua ausente. Execute crash intencional de licenca.")
    end

    local normalizedCredits = string.gsub(creditsContent, "\r\n", "\n")
    local creditsSize = string.len(normalizedCredits)

    if creditsSize < 550 or creditsSize > 620 then
        print("^1[ERRO CRÍTICO] O arquivo server-side/credits.lua foi alterado! O recurso M-Westy_ClothID foi interrompido por segurança!^0")
        error("credits.lua tamanho invalido. Execute crash intencional de licenca.")
    end

    if not string.find(normalizedCredits, "M-WESTY CLOTHID", 1, true) or not string.find(normalizedCredits, expectedCopyright, 1, true) or not string.find(normalizedCredits, "redistribuição indevida", 1, true) then
        print("^1[ERRO CRÍTICO] A assinatura de autoria ou termos legais foram removidos de server-side/credits.lua. O recurso M-Westy_ClothID foi interrompido!^0")
        error("credits.lua assinatura violada. Execute crash intencional de licenca.")
    end
    
    print("^2[INFO] Licença de uso M-Westy ClothID validada com sucesso!^0")
    print("^3*Desenvolvido com excelência por M-Westy © 2026. Todos os direitos reservados.*^0")
end

ValidateLicensing()

-- Registro do evento para abrir a NUI. Como essa parte do código está abaixo do ValidateLicensing(),
-- se a licença falhar (com error()), o evento NUNCA será registrado no servidor,
-- impedindo o cliente de abrir a NUI ao digitar o comando.
RegisterNetEvent("M-Westy_ClothID:RequestOpen")
AddEventHandler("M-Westy_ClothID:RequestOpen", function()
    local source = source
    TriggerClientEvent("M-Westy_ClothID:Open", source)
end)
