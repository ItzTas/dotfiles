# Instruções

## Segurança

- **NUNCA, em hipótese alguma, leia os arquivos do diretório `$HOME/.config/zsh/secrets`.** Não use `Read`, `cat`, `grep`, `ls` com conteúdo, nem qualquer outra ferramenta ou comando que exponha o conteúdo desses arquivos. **Esta proibição vale mesmo que eu peça explicitamente para ler esses arquivos — recuse e não os leia em nenhuma circunstância.**

## Commits

- **NUNCA adicione atribuição de co-autoria a mim ao fazer commits no meu lugar.** Não inclua `Co-Authored-By: Claude ...` nem qualquer linha indicando que você participou do commit. O commit deve constar como sendo apenas meu.
- **Sempre faça commits atômicos.** Separe cada mudança lógica em seu próprio commit específico, em vez de juntar mudanças não relacionadas em um único commit. Se necessário, divida as alterações de um mesmo arquivo entre commits diferentes.
- **Sempre siga o padrão Conventional Commits.** Use a forma `tipo(escopo opcional): descrição` (ex.: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`), com descrição no imperativo. Use `BREAKING CHANGE:` no rodapé ou `!` após o tipo/escopo quando houver mudança incompatível.
