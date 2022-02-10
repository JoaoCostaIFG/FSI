# CTF 8

## Desafio #1

Pela análise do código fonte, é possível ver que o código é vulnerável a SQL Injection attacks 
tanto no campo do username como na password. Existem várias formas de atacar esta vulnerabilidade.
Nós escolhemos comentar a validação da password:

```
username: admin'--
password: anything
```
### Flag 

`flag{0ec8a1214f8ad847d8c3e75111157ad6}`

## Desafio #2

### Que funcionalidades é que estão acessiveis a um utilizador sem este estar autenticado?
- Dar login
- Ver um gif
- Dar ping a um host

### Será que estão a utilizar algum utilitário linux? 
Sim. O ping de hosts usa o utilitário ping do UNIX.

### Se sim, que vulnerabilidades podem estar presentes na chamada deste utilitário?
Se for uma chamada à shell, podemos encadiar outros comandos.

### Verifica se existe alguma vulnerabilidade nesta funcionalidade.
Encadeamos comandos para ler o ficheiro da flag: `-c 1 8.8.8.8; cat /flag.txt`

### Flag
flag{aaf61f6f1c810ec48e1107e770804029}
