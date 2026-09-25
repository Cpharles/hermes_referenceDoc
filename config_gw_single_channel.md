e para isso vamos rodar um script no terminal para completar esta configuração.

> [!NOTE] Para entendendo o que cada linha do script faz, leia os seguintes arquivos:
> ⇒ [create-profile_win.md](./telegram/scripts/create-profile_win.md)
> Ou exponha estes arquivos para uma IA e peça as explicações e verificações de segurança.

* Para sistemas operacionais Windows utilize o arquivo [create-profile_win.sh](./telegram/scripts/create-profile_win.sh)
* Para sistemas operacionais Linux utilize o arquivo [create-profile_lin.sh](./telegram/scripts/create-profile_lin.sh)

Os comando podem ser diferentes conforme o sistema operacional. Como neste caso eu estou rodando em uma máquina local e a maioria das pessoas utiliza Windows, vou dar o exemplo utilizando comando para o OS Windows, mas a lógica continua a mesma para qualque OS.

### Step 2. Verificando o status dos profiles no Hermes

> [!NOTE]
> Como vamos trabalhar com vários profiles o ideal é utilizar um gateway multiplex, pois desta forma facilita o gerenciamento do gateway, já que os profiles ficam legado a apenas um PID, ou seja compartilham do mesmo gateway.
> Para fazer isso temos que migrar o tipo de gateway padrão single para o padrão multiplex através do comando:
> `hermes gateway migrate --multiplex 2>&1`
> Para mais informação consulte a documentação

3. Agora abra o arquivo [create-profile_win.sh](./telegram/scripts/create-profile_win.sh) em um editor de coódigo (IDE) de sua preferência:
    Este são alguns exemplos, mas tem uma dezena de IDE para códigos
    * [Visual Studio Code_MicroSoft](https://code.visualstudio.com/download?_exp_download=fb315fc982)
    * [Antigravity IDE_Google](https://antigravity.google/product/antigravity-ide)
    * [NotePad++](https://notepad-plus-plus.org/downloads/)

    Edite o arquivo e coloque **NOME**, **MEU_ID**, **TOKEN** que se encontra no início do script (use a planilha [profile_list.xlsx](./telegram/profiles_list.xlsx) para auxiliar).
    Exemplo:

    ```bash
    NOME=time-perfomance
    MEU_ID=(gerado no item 1 ao rodar o @userinfobot)
    TOKEN=(gerado no item 2 quando criado o bot)
    ```

4. Salve o arquivo e depois retorne ao terminal Bash;
5. Navegue pelo terminal até a pasta onde se encontra os arquivos;
6. Execute o script com o seguinte comando:  

    ```bash
    bash create-profile_win.sh
    ```

7. Aguarde o processor finalizar acompanhando os outputs no terminal;
8. Depois, abra novamente o arquivo e altere os dados para o próximo agente e repita a execução do script;
9. Continue repetindo este processo até cadastrar todos os profiles.
10. Para conferirmos se todos os agentes foram cadastrados no Hermes, execute novamente o comando no terminal:

    ```bash
    hermes profile list
    ```

    Vamos ter algo como:

    ![status2](./telegram/img/status_profile2.png)

11. Para ambiente windows localmente não podemos fechar o terminal, caso contrario os processos dos gateways dos profiles serão encerrados. Já para ambiente VPS isso não oscorre pois o sistema fica rodando 24/7 e só será necessário reiniciar caso seja realmente necessário.

### Step 3. Reativando os Gateways dos Profiles

Sempre que você estiver rodando localmente em uma VPS em ambiente Linux/Windows será necessário a reativação dos gateways para os profiles de forma manual sempre que:

1. Atualizar o Hermes Agent
2. Precisou parar o Hermes por algum motivo
3. O servidor (VPS) foi reiniciado

Nestes casos podemos primeiramente executar o comando (`hermes profile list`) para verificar se os gateways estão com status **running** ou **stopped**.

```text
              Hermes Gateway
                    │
                    │
          ┌─────────┴─────────┐
          │                   │
       default             profiles
       stopped             stopped
```

Para forçarmos a reativação dos gateway abra o terminal e execute o comando para cada profile ou execute o script:

#### ⟹ Para sistemas operacionais Windows utilize:

1. Executando por comando para cada profile.

    ```bash
    hermes -p <profile_name> gateway run --replace > /tmp/<profile_name>-gateway.log 2>&1 &
    sleep 8
    hermes gateway list
    ```

2. Executando por Script -> [wakeup-gateway_win.sh](./telegram/scripts/wakeuo-gateway_win.sh)
3. E para ver as portas que cada Gateway esta rodando utilize o comando `hermes gateway list`

    ![statusgateway](./telegram/img/status_profile3.png)

#### ⟹ Para sistemas operacionais Linux utilize:

1. Executando por comando para cada profile.

    ```bash
    setsid hermes -p <profile_name> gateway run --replace > /tmp/<profile_name>-gateway.log 2>&1 &
    sleep 8
    hermes gateway list
    ```

2. Executando por escript -> [wakeup-gateway_lin.sh](./telegram/scripts/wakeup-gateway_lin.sh)
3. E para ver as portas que cada Gateway esta rodando utilize o comando `hermes gateway list`

> [!NOTE]
    Se estiver rodando o Hermes Agent App localmente em um PC (não em uma VPS), neste caso não será necessário este procedimento, pois o App já vai subir os gateway automaticamente.
    Caso algum profile não suba, consulte o log localizado no diretório do próprio profile que está em **`profiles/<profile_name>/logs/gateway.log`**
