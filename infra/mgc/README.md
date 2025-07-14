## Terraform for MGC

> Essa parte está em PT/BR

[mgc-provider](https://registry.terraform.io/providers/MagaluCloud/mgc/latest)

Caso queira experimentar a MagaluCloud, configure os arquivos da root da maneira padrão (com especificada no [README.md](/README.md)). Após isso, abra o [console](https://console.magalu.cloud/), vá ao `menu` (canto superior esquerdo) e ative a função de `preview`.

Para começar, crie um grupo de segurança que expõe (TCP) as portas `:80`, `:443` e para o docker-swarm, as portas `:2377`, `:7946` e `:4789`. No momento isso precisa ser feito pelo console de fato (ainda não funciona pelo Terraform).

> NOTE: A CLI parece não estar completamente funcional na parte de VPCs/SubNets, então estamos utilizando a `VPC Default` (trecho dos mainfests está comentado apenas).

Após isso, cheque o [variables.tf](/infra/variables.tf) e complete seu `.tfvars` com os dados. Lembre-se de se autenticar na [CLI da MagaluCloud](https://docs.magalu.cloud/docs/devops-tools/cli-mgc/how-to/download-and-install/):

```sh
mgc auth login
```

Após isso, basta rodar:

```sh
terraform init
terraform plan -var-file=".tfvars"
terraform apply -var-file=".tfvars"
```

e...pronto! O terrafom irá gerar o output com os IPs das máquinas (o [hosts/hosts.ini](/hosts/hosts.ini) já foi gerado automaticamente). Lembre de adicionar os IPs públicos dos managers em seu DNS. Agora volte à [root do repositório](/) e siga o tutorial.
