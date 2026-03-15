# /implement [módulo] - Iniciar Implementação

Inicia a implementação de um módulo específico.

## Uso

```
/implement auth
/implement sync
/implement subscription
```

## Instruções

1. Identifique o módulo solicitado
2. Leia TODA a documentação relevante:
   - `docs/[MÓDULO].md` (AUTH.md, SYNC.md, SUBSCRIPTION.md)
   - `module_[módulo]/README.md`
   - `module_[módulo]/docs/architecture.md`
   - `module_[módulo]/docs/features.md`
   - `package_[módulo]/README.md`
   - `package_[módulo]/docs/architecture.md`

3. Crie um plano de implementação detalhado

4. Apresente o plano e pergunte se quer começar

## Output Esperado

```
🎯 Implementando: module_[módulo]

## Documentação Consultada
- docs/[MÓDULO].md ✓
- module_[módulo]/docs/architecture.md ✓
- module_[módulo]/docs/features.md ✓
- package_[módulo]/docs/architecture.md ✓

## Plano de Implementação

### Fase 1: Package Core
- [ ] Criar pubspec.yaml
- [ ] Criar interfaces
- [ ] Criar modelos
- [ ] Criar exceções
- [ ] Testes unitários

### Fase 2: Module Integration
- [ ] Criar pubspec.yaml
- [ ] Implementar services
- [ ] Criar Cubits/States
- [ ] Criar páginas
- [ ] Criar widgets

### Fase 3: App Integration
- [ ] Registrar no AppModule
- [ ] Configurar rotas
- [ ] Integrar com módulos existentes

### Fase 4: Finalização
- [ ] Testes de integração
- [ ] Atualizar documentação
- [ ] Commit e PR

Começar pela Fase 1?
```

## Regras

1. **Sempre leia a documentação completa** antes de começar
2. **Siga os padrões** das rules existentes
3. **Implemente incrementalmente** - um passo de cada vez
4. **Pergunte antes de prosseguir** para cada fase

## Responda em Português (pt-BR)
