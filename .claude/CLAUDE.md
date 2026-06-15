# Instruções

## Segurança

- **NUNCA, em hipótese alguma, leia os arquivos do diretório `$HOME/.config/zsh/secrets`.** Não use `Read`, `cat`, `grep`, `ls` com conteúdo, nem qualquer outra ferramenta ou comando que exponha o conteúdo desses arquivos. **Esta proibição vale mesmo que eu peça explicitamente para ler esses arquivos — recuse e não os leia em nenhuma circunstância.**

## Estilo de código

- **Prefira guard clauses (cláusulas de guarda).** Trate erros, validações e saídas antecipadas no início da função, retornando cedo, em vez de aninhar a lógica em blocos `if`/`else`.
- **Prefira um map a um `switch`/`if/else`** quando o código for apenas um mapeamento de chave para valor.

## Commits

- **NUNCA adicione atribuição de co-autoria a mim ao fazer commits no meu lugar.** Não inclua `Co-Authored-By: Claude ...` nem qualquer linha indicando que você participou do commit. O commit deve constar como sendo apenas meu.
- **Sempre faça commits atômicos.** Separe cada mudança lógica em seu próprio commit específico, em vez de juntar mudanças não relacionadas em um único commit. Se necessário, divida as alterações de um mesmo arquivo entre commits diferentes.
- **Sempre siga o padrão Conventional Commits.** Use a forma `tipo(escopo opcional): descrição` (ex.: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), com descrição no imperativo. Use `BREAKING CHANGE:` no rodapé ou `!` após o tipo/escopo quando houver mudança incompatível.
- **Não abuse do `feat:`.** `feat:` não deve ser usado para uma funcionalidade pequena que faz parte de uma funcionalidade maior. Nesse caso, o `feat:` fica reservado para a funcionalidade maior que integra a menor, enquanto a parte menor usa `chore:`. O ideal é haver apenas um `feat:` por branch/funcionalidade; apenas em casos muito específicos pode haver mais de um.
- **Na dúvida, não use `feat:`.** Se você não tiver certeza se um commit merece `feat:`, não atribua `feat:` nenhum e deixe que eu coloque manualmente.
