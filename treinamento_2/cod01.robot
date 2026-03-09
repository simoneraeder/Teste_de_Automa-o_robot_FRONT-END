*** Settings ***
Library          SeleniumLibrary

Test Setup    Run Keywords
...    Open Browser    url=${URL}    browser=${BROWSER}    AND
...    Maximize Browser Window

Test Teardown    Close Browser

*** Variables ***

### Dados de configuração ###

${URL}         https://www.saucedemo.com
${BROWSER}     chrome

### Massa de teste ###
${USUARIO_LENTO}    performance_glitch_user
${USUARIO_VALIDO}    standard_user
${USUARIO_INVALIDO}    locked_out_user
${SENHA}    secret_sauce

### Page Object Model (POM) ###

&{LOGIN_PAGE}
...    UsernameInput=id:user-name
...    PasswordInput=id:password
...    LoginButton=id:login-button
...    ErrorMessage=css:[data-test=error]

&{HOME_PAGE}
...    BotaoPack=id:add-to-cart-sauce-labs-backpack
...    Carrinho=class:shopping_cart_link

&{CARRINHO_PAGE}
...    BotaoCheckout=id:checkout

&{CHECKOUT_PAGE}
...    FirstName=id:first-name
...    LastName=id:last-name
...    Zip=id:postal-code
...    BtnContinue=id:continue
...    BtnFinish=id:finish
...    MensagemSucesso=class:complete-header

*** Keywords ***

### Ações ###

Realizar login com ${usuario_input} e ${senha_input}
    Wait Until Element Is Visible    ${LOGIN_PAGE.UsernameInput}    10s
    Input Text    ${LOGIN_PAGE.UsernameInput}    ${usuario_input}
    Input Text    ${LOGIN_PAGE.PasswordInput}    text=${senha_input}
    Click Element    ${LOGIN_PAGE.LoginButton}
    
Clicar no botão de comprar 1 item
    # Primeiro item
    Wait Until Element Is Visible    ${HOME_PAGE.BotaoPack}    20s
    Click Element    ${HOME_PAGE.BotaoPack}

    # Aguarda o badge do carrinho atualizar
    Wait Until Element Contains    class:shopping_cart_badge    1    15s
   
Ir para o carrinho
    Wait Until Element Is Visible    ${HOME_PAGE.Carrinho}    30s
    Click Element    ${HOME_PAGE.Carrinho}
    Wait Until Element Contains    class:shopping_cart_badge    1    15s
    Element Should Contain        class:shopping_cart_badge    1
    Wait Until Element Is Visible    ${CARRINHO_PAGE.BotaoCheckout}    30s

Clicar para finalizar a compra
   Wait Until Element Is Visible    ${CARRINHO_PAGE.BotaoCheckout}    20s
   Click Element    ${CARRINHO_PAGE.BotaoCheckout}

Preencher dados de cadastro e finalizar
    Input Text    ${CHECKOUT_PAGE.FirstName}    Simone
    Input Text    ${CHECKOUT_PAGE.LastName}    Raeder
    Input Text    ${CHECKOUT_PAGE.Zip}    12345-678
    Click Element     ${CHECKOUT_PAGE.BtnContinue}

Finalizar de vez
    Wait Until Element Is Visible    ${CHECKOUT_PAGE.BtnFinish}
    Click Element    ${CHECKOUT_PAGE.BtnFinish}
    Element Should Contain    ${CHECKOUT_PAGE.MensagemSucesso}    Thank you for your order!

### Verificações ###

Verificar se conseguiu realizar o login corretamente
    ${url}=    Get Location
    Should Contain    container=${url}    item=/inventory.html

Verificar se não foi possível realizar o login
    ${mensagem_obtida}    Get Text    ${LOGIN_PAGE.ErrorMessage}
    ${mensagem_esperada}    Set Variable    Epic sadface: Sorry, this user has been locked out.
    Should Be Equal    first=${mensagem_obtida}    second=${mensagem_esperada}

Verificar se a mensagem de troca de senha apareceu e clica em agora não ou fechar
    ${status}=    Run Keyword And Return
    Status    Element
    Should Be Visible    id:botao-fechar-aviso
        IF    ${status}
        Click Element    id:botao-fechar-aviso
        END


*** Test Cases ***

TC001 - Realizar login com usuário válido
    [Tags]    Válido
    Realizar login com ${USUARIO_VALIDO} e ${SENHA}
    Verificar se conseguiu realizar o login corretamente
    Sleep    time_=2s

TC002 - Realizar login com usuário inválido
    [Tags]    INVÁLIDO  
    Realizar login com ${USUARIO_INVALIDO} e ${SENHA}
    Verificar se não foi possível realizar o login
    Sleep    time_=2s

TC003 - Após Logar com usuário válido, comprar 1 item
    [Tags]    COMPRA
    Realizar login com ${USUARIO_VALIDO} e ${SENHA}
    Clicar no botão de comprar 1 item
    Ir para o carrinho
    Clicar para finalizar a compra
    Preencher dados de cadastro e finalizar
    Finalizar de vez

     