# Atividade Docker + CI — Leonam

## Informações

**Aluno(a):** Leonam
**Turma:** Vespertino
**Data:** 27/07/2026
**Aplicação utilizada:** docker/getting-started-app (To-Do em Node.js)

---

## 1. Como executar este projeto

```bash
git clone https://github.com/leonamdesousa/meu-projeto-doker.git
cd meu-projeto-doker
cp .env.example .env
docker compose up -d --build
```

Acesse:

http://localhost:3000

Para derrubar os containers:

```bash
docker compose down
```
Mantém os dados.

Ou:

```bash
docker compose down -v
```
Apaga também os volumes e os dados.

---

## 2. Imagem e Dockerfile Multi-Stage

**Estágios utilizados:**
- **builder:** instala as dependências da aplicação Node.js.
- **estágio final:** copia apenas o `node_modules` e o código-fonte necessários para executar a aplicação, gerando uma imagem mais enxuta.

**Imagem base**
`node:20-alpine`

**Usuário de execução**
`appuser` [não-root]

**Tamanho final da imagem**
[confira o valor exato de `CONTENT SIZE` no seu `docker images`]

### Por que o Multi-Stage ajuda?

O Dockerfile multi-stage reduz o tamanho total da imagem final, pois usa uma etapa apenas para instalar as dependências (com ferramentas de build que não precisam ir para produção) e outra etapa, separada, só com os arquivos necessários para executar a aplicação. Isso deixa a imagem mais leve e mais segura, já que reduz a superfície de ataque ao não carregar nada além do estritamente necessário.

**Print 1 — Build + Docker Images**
![Build + Docker Images](docs/imagens/01-docker-build-images.png)

**Print 2 — Aplicação rodando**
![Aplicação rodando](docs/imagens/02-app-rodando.png)

---

## 3. Volumes e Persistência

**Volume utilizado**
`todo-db`

**Montado em**
`/etc/todos`

**Print 3 — Sem Volume**
Após recriar o container, os dados desapareceram.
![Perda de dados sem volume](docs/imagens/03-sem-volume.png)

**Print 4 — Com Volume**
Após recriar o container, os dados permaneceram.
![Persistência com volume](docs/imagens/04-com-volume.png)

![docker volume ls](docs/imagens/05-docker-volume-ls.png)

### Diferença entre `docker compose down` e `docker compose down -v`

O comando `docker compose down` remove apenas os containers e a rede, mantendo os volumes e os dados. Já `docker compose down -v` remove também os volumes, apagando permanentemente os dados armazenados.

---

## 4. Rede

**Rede criada**
`todo-net`

**Serviços conectados**
- `app`
- `db`

**A porta do banco está exposta ao host?**
Não. O banco de dados está acessível apenas pela rede interna do Docker, permitindo que somente a aplicação consiga se conectar a ele.

### Por que o app consegue chamar o host `mysql` sem saber o IP?

Porque o Docker fornece um DNS interno para as redes que ele cria, permitindo que os containers se comuniquem usando o nome do serviço (ou o alias de rede) em vez do endereço IP.

**Print 5 — docker network inspect**
![docker network inspect](docs/imagens/06-network-inspect.png)

**Print 6 — SELECT no MySQL**
![SELECT no MySQL](docs/imagens/07-select-todo-items.png)

---

## 5. Docker Compose

**Serviços**
- `app`
- `db`

**Rede**
`todo-net`

**Volume**
`todo-mysql-data`

**Healthcheck**
`db`

**depends_on**
`condition: service_healthy`

**Variáveis sensíveis**
Carregadas através do arquivo `.env`, que não é versionado. O arquivo `.env.example` serve como modelo.

**Print 7 — docker compose ps**
![docker compose ps](docs/imagens/08-compose-ps.png)

---

## 6. Integração Contínua (GitHub Actions)

**Workflow**
`.github/workflows/ci.yml`

**Gatilhos**
- `push`
- `pull_request`

**O pipeline faz**
- Valida o arquivo `compose.yaml`
- Builda a imagem
- Sobe a stack utilizando Docker Compose
- Aguarda a aplicação responder
- Cria uma tarefa via API (Smoke Test)
- Derruba a stack

**Print 8 — Execução verde**
![Execução verde no Actions](docs/imagens/09-ci-verde.png)

---

## 7. Quebra proposital do CI

**O que foi alterado?**
[descreva aqui exatamente o que você mudou — ex: caminho errado no CMD do Dockerfile / variável MYSQL_PASSWORD removida do compose / rota do smoke test trocada / indentação inválida no compose.yaml]

**Erro apresentado**
```
[cole aqui o trecho exato do log de erro]
```

**Como o CI reagiu?**
[descreva em qual etapa o pipeline falhou e por quê]

**Como foi corrigido?**
[descreva a correção aplicada]

**Link do Pull Request**
[cole aqui o link do seu PR/run no GitHub Actions]

**Print 9 — Execução vermelha**
![Execução vermelha no Actions](docs/imagens/10-ci-vermelho.png)

---

## 8. Dificuldades e aprendizados

Durante essa atividade tive dificuldade principalmente na configuração do `.env` — o Docker Compose não estava lendo as variáveis porque o arquivo tinha nome errado (`.env.exemple` em vez de `.env`, e o `.env` real ainda não existia). Também precisei entender melhor como funciona a autenticação do Git com o GitHub via HTTPS, já que a senha normal não é mais aceita e é preciso usar um Personal Access Token — inclusive descobri que, para conseguir subir um workflow (`.github/workflows/`), o token precisa do escopo `workflow` além do `repo`. Com esse projeto aprendi na prática como funciona o multi-stage build, como o Docker resolve nomes de containers via DNS interno na rede, e como o `healthcheck` combinado com `depends_on: condition: service_healthy` evita problemas de race condition entre o app e o banco.

---

## CD — Publicação no Docker Hub

**Aluno(a):** Leonam
**Turma:** [sua turma]

**Usuário do Docker Hub:** leonam1515

**Imagem publicada:**
`leonam1515/meu-projeto-docker:latest`

**Link da imagem no Docker Hub:**
[cole aqui o link do seu repositório de imagem no Docker Hub]

**Dispara quando:** push na branch `main`

**Arquivo do workflow:**
`.github/workflows/cd.yml`

### Evidências

**Print 1 — Token criado no Docker Hub**
![Token Docker Hub](docs/imagens/11-dockerhub-token.png)

**Print 2 — Secrets cadastrados no GitHub (DOCKERHUB_USERNAME e DOCKERHUB_TOKEN)**
![Secrets GitHub](docs/imagens/12-github-secrets.png)

**Print 3 — Workflow de CD executado com sucesso na aba Actions**
![Workflow Actions](docs/imagens/13-cd-verde.png)

**Print 4 — Imagem publicada no Docker Hub**
![Imagem Docker Hub](docs/imagens/14-imagem-dockerhub.png)

**Print 5 — Comando docker pull baixando a imagem publicada**
![Docker Pull Imagem Baixada](docs/imagens/15-docker-pull.png)

### Respostas

**1. O que é o Docker Hub?**
É um serviço de armazenamento e distribuição de imagens Docker na nuvem — funciona como um repositório de imagens, de forma parecida com o GitHub para código-fonte.

**2. Qual a diferença entre CI e CD?**
CI (Integração Contínua) automatiza o build, os testes e a validação do código sempre que uma alteração é enviada ao repositório, com o objetivo de identificar problemas rapidamente. CD (Entrega/Implantação Contínua) vem depois do CI: automatiza a publicação do artefato já validado — nesse caso, a imagem Docker — em um destino como o Docker Hub.

**3. Por que usar token e GitHub Secrets em vez de escrever usuário e senha no `cd.yml`?**
Porque o arquivo do workflow fica público no repositório, e colocar credenciais em texto puro as exporia a qualquer pessoa que veja o código. Os Secrets do GitHub são criptografados e só ficam disponíveis durante a execução do workflow, e um token pode ser revogado a qualquer momento sem precisar trocar a senha da conta.

**4. O que significa a tag `latest`?**
É a tag padrão que identifica a versão mais recente publicada de uma imagem. Quando um `docker pull` é executado sem especificar nenhuma tag, o Docker baixa automaticamente a versão `latest`.

---

## 9. Checklist

- [x] Dockerfile Multi-Stage funcionando
- [x] `.dockerignore` presente
- [x] Container não roda como root
- [x] Volume nomeado com persistência demonstrada
- [x] Rede nomeada
- [x] Banco não exposto ao host
- [x] `compose.yaml` sobe tudo com um comando
- [x] `.env` no `.gitignore`
- [x] `.env.example` versionado
- [x] CI funcionando (verde)
- [ ] Pull Request com CI vermelho documentado
- [x] Todos os 9 prints adicionados ao README
