## Terraform for MGC

> Essa parte está em PT/BR

[mgc-provider](https://registry.terraform.io/providers/MagaluCloud/mgc/latest)

Caso queira experimentar a MagaluCloud, configure os arquivos da root da maneira padrão (com especificada no [README.md](/README.md)). Após isso, abra o [console](https://console.magalu.cloud/), vá ao `menu` (canto superior esquerdo) e ative a função de `preview`.

Para começar, crie um grupo de segurança que expõe (TCP) as portas `:80`, `:443` e para o docker-swarm, as portas `:2377`, `:7946` e `:4789`. No momento isso precisa ser feito pelo console de fato (ainda não funciona pelo Terraform).

> NOTE: A CLI parece não estar completamente funcional na parte de VPCs/SecurityGroups, então adicione as regras ao security group padrão. Isso pois precisamos do ID dos security groups para adicionar ao [variables.tf](/infra/variables.tf).

Após isso, cheque o [variables.tf](/infra/variables.tf) e complete-o com os dados.
