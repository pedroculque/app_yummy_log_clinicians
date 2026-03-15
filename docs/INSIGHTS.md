# Insights - Especificação Técnica

Documentação da feature de Insights para o YummyLog for Clinicians.

---

## Visão Geral

A tela de Insights transforma dados brutos do diário alimentar em **informação acionável** para o clínico. O foco é identificar **padrões**, **alertas** e **tendências** que ajudem na tomada de decisão clínica.

---

## Dados Disponíveis

### Patient (paciente vinculado)

| Campo | Tipo | Uso em Insights |
|-------|------|-----------------|
| `id` | `String` | Identificador único |
| `name` | `String` | Exibição |
| `photoUrl` | `String?` | Avatar |
| `linkedAt` | `DateTime?` | Tempo de acompanhamento |

### MealEntry (refeição registrada)

| Campo | Tipo | Uso em Insights |
|-------|------|-----------------|
| `mealType` | `MealType` | Análise por tipo de refeição |
| `dateTime` | `DateTime` | Frequência, timeline |
| `feelingLabel` | `FeelingLabel?` | Análise de sentimentos |
| `amountEaten` | `AmountEaten?` | Detecção de restrição |
| `hiddenFood` | `bool?` | 🟠 Alerta médio |
| `regurgitated` | `bool?` | 🟠 Alerta médio |
| `forcedVomit` | `bool?` | 🔴 Alerta alto |
| `ateInSecret` | `bool?` | 🟡 Monitorar |
| `usedLaxatives` | `bool?` | 🔴 Alerta alto |

### Enums

```dart
enum MealType { breakfast, lunch, dinner, supper, morningSnack, afternoonSnack, eveningSnack }
enum AmountEaten { nothing, aLittle, half, most, all }
enum FeelingLabel { sad, nothing, happy, proud, angry }
```

---

## Métricas Calculadas

### 1. Dashboard Resumo

| Métrica | Cálculo | Relevância Clínica |
|---------|---------|-------------------|
| **Pacientes ativos** | Total vinculados + % com registros nos últimos 7 dias | Adesão ao tratamento |
| **Registros esta semana** | Total de refeições de todos pacientes (últimos 7 dias) | Engajamento geral |
| **Alertas ativos** | Contador de comportamentos de risco (últimos 7 dias) | Priorização |

### 2. Alertas de Comportamentos de Risco

| Comportamento | Campo | Prioridade | Cor |
|---------------|-------|------------|-----|
| Vômito forçado | `forcedVomit` | Alta | 🔴 Vermelho |
| Uso de laxantes | `usedLaxatives` | Alta | 🔴 Vermelho |
| Regurgitação | `regurgitated` | Média | 🟠 Laranja |
| Esconder comida | `hiddenFood` | Média | 🟠 Laranja |
| Comer em segredo | `ateInSecret` | Baixa | 🟡 Amarelo |

### 3. Score de Atenção (Ranking)

```dart
int calculateAttentionScore(Patient patient, List<MealEntry> meals) {
  int score = 0;
  final last7Days = meals.where((m) => m.dateTime.isAfter(DateTime.now().subtract(Duration(days: 7))));
  
  // Comportamentos de risco (peso alto)
  score += last7Days.where((m) => m.forcedVomit == true).length * 10;
  score += last7Days.where((m) => m.usedLaxatives == true).length * 10;
  score += last7Days.where((m) => m.regurgitated == true).length * 5;
  score += last7Days.where((m) => m.hiddenFood == true).length * 5;
  score += last7Days.where((m) => m.ateInSecret == true).length * 3;
  
  // Sentimentos negativos (peso médio)
  score += last7Days.where((m) => m.feelingLabel == FeelingLabel.sad).length * 2;
  score += last7Days.where((m) => m.feelingLabel == FeelingLabel.angry).length * 2;
  
  // Restrição alimentar (peso médio)
  score += last7Days.where((m) => m.amountEaten == AmountEaten.nothing).length * 3;
  score += last7Days.where((m) => m.amountEaten == AmountEaten.aLittle).length * 1;
  
  // Baixa frequência (peso baixo)
  if (last7Days.length < 7) score += 5; // menos de 1 refeição/dia
  
  return score;
}
```

### 4. Análise de Sentimentos

| Sentimento | Emoji | Cor | Interpretação |
|------------|-------|-----|---------------|
| `proud` | 🌟 | Verde | Positivo |
| `happy` | 😊 | Verde claro | Positivo |
| `nothing` | 😐 | Cinza | Neutro |
| `sad` | 😢 | Laranja | Negativo |
| `angry` | 😠 | Vermelho | Negativo |

### 5. Análise de Quantidade

| Quantidade | Campo | Interpretação |
|------------|-------|---------------|
| Nada | `nothing` | 🔴 Restrição severa |
| Um pouco | `aLittle` | 🟠 Restrição |
| Metade | `half` | 🟡 Abaixo do esperado |
| Maior parte | `most` | ✅ Adequado |
| Tudo | `all` | ✅ Adequado |

---

## Estrutura de Navegação

```
Tab Insights
├── Dashboard (visão geral)
│   ├── Cards resumo (pacientes, registros, alertas)
│   ├── Alertas recentes (comportamentos de risco)
│   └── Ranking de atenção (pacientes ordenados)
│
└── [Futuro] Detalhes por paciente
    ├── Sentimentos (gráfico)
    ├── Frequência (calendário)
    └── Quantidade (distribuição)
```

---

## Modelos de Dados

### PatientInsight

```dart
class PatientInsight extends Equatable {
  final Patient patient;
  final int attentionScore;
  final int mealsLast7Days;
  final int alertsLast7Days;
  final Map<FeelingLabel, int> feelingDistribution;
  final Map<AmountEaten, int> amountDistribution;
  final List<RiskAlert> recentAlerts;
}
```

### RiskAlert

```dart
class RiskAlert extends Equatable {
  final String patientId;
  final String patientName;
  final RiskType type;
  final DateTime dateTime;
  final RiskPriority priority;
}

enum RiskType { forcedVomit, usedLaxatives, regurgitated, hiddenFood, ateInSecret }
enum RiskPriority { high, medium, low }
```

### InsightsSummary

```dart
class InsightsSummary extends Equatable {
  final int totalPatients;
  final int activePatients; // com registros nos últimos 7 dias
  final int totalMealsThisWeek;
  final int totalAlerts;
  final List<RiskAlert> recentAlerts;
  final List<PatientInsight> patientInsights;
}
```

---

## Considerações UX

1. **Empty states:** Cada seção deve ter mensagem quando não há dados suficientes
2. **Período mínimo:** Sugerir "Aguarde 7 dias de registros para insights mais precisos"
3. **Ação clara:** Cada insight deve ter CTA (ver diário do paciente)
4. **Cores consistentes:** Usar sistema de cores do ui_kit

---

## Considerações Clínicas

1. **Não diagnosticar:** Insights são para **apoio à decisão**, não diagnóstico automático
2. **Contexto importa:** Alertas devem ser avaliados junto com histórico do paciente
3. **Sensibilidade:** Comportamentos de risco são indicadores, não certezas
4. **Evolução:** Focar em tendências, não em eventos isolados

---

## Referências

- [REQUIREMENTS.md](../REQUIREMENTS.md) - Requisitos C23-C30
- [ROADMAP.md](ROADMAP.md) - Fases 3.1, 3.2, 3.3
- [patients_feature](../modules/features/patients/) - Modelos Patient e MealEntry
