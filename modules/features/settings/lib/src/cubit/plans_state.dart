/// Estado da UI de planos (paywall): período escolhido e compra em curso.
class PlansUiState {
  const PlansUiState({
    this.isAnnual = true,
    this.purchaseBusy = false,
  });

  final bool isAnnual;
  final bool purchaseBusy;

  PlansUiState copyWith({
    bool? isAnnual,
    bool? purchaseBusy,
  }) {
    return PlansUiState(
      isAnnual: isAnnual ?? this.isAnnual,
      purchaseBusy: purchaseBusy ?? this.purchaseBusy,
    );
  }
}
