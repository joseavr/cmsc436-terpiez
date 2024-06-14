import 'package:terpiez/models/models.dart';

/// Removes caught terpiez from the terpiez locations
/// and returns a new terpiez locations (not in-place).
///
/// @param fromCaughtTerpiez - list of caught terpiez
///
/// @param toUpdateLocations - list of terpiez locations
///
/// @return - list of terpiez locations
List<TerpLocation> updateTerpiezLocations(List<CaughtTerpiez> fromCaughtTerpiez,
    List<TerpLocation> toUpdateLocations) {
  if (fromCaughtTerpiez.isEmpty) return toUpdateLocations;

  // copy the terpiez locations
  List<TerpLocation> toUpdateLocationsCopy = [...toUpdateLocations];

  for (final caughtTerp in fromCaughtTerpiez) {
    List<TerpLocation> caughtLocations = caughtTerp.caughtLocations;
    toUpdateLocationsCopy.removeWhere((location) =>
        location.terpiezId == caughtTerp.id &&
        (caughtLocations.any(
          (caught) => caught.compareLatLng(location.latLng),
        )));
  }

  return toUpdateLocationsCopy;
}
